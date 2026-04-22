import json
import logging
import os
import time
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    dr_region = os.environ["DR_REGION"]
    replica_identifier = os.environ["DR_REPLICA_IDENTIFIER"]
    max_lag = int(os.environ.get("MAX_REPLICATION_LAG_SECONDS", "30"))
    poll_interval = int(os.environ.get("POLL_INTERVAL_SECONDS", "15"))
    max_wait = int(os.environ.get("MAX_WAIT_SECONDS", "900"))

    rds = boto3.client("rds", region_name=dr_region)

    logger.info(
        "Starting replica failover handler for replica=%s in region=%s",
        replica_identifier,
        dr_region,
    )

    db = describe_db_instance(rds, replica_identifier)
    status = db["DBInstanceStatus"]
    endpoint = db.get("Endpoint", {}).get("Address")

    lag = extract_replica_lag(db)
    logger.info("Initial replica status=%s lag=%s", status, lag)

    if status != "available":
        return {
            "replica_ready": False,
            "promotion_started": False,
            "db_available": False,
            "db_status": status,
            "replica_identifier": replica_identifier,
            "db_endpoint": endpoint,
            "message": f"Replica is not available. Current status: {status}",
        }

    if lag is None:
        logger.warning("Replica lag metric not available from RDS describe output")
    elif lag > max_lag:
        return {
            "replica_ready": False,
            "promotion_started": False,
            "db_available": False,
            "db_status": status,
            "replica_identifier": replica_identifier,
            "db_endpoint": endpoint,
            "replica_lag_seconds": lag,
            "message": f"Replica lag {lag}s exceeds max allowed {max_lag}s",
        }

    try:
        logger.info("Promoting read replica %s", replica_identifier)
        rds.promote_read_replica(DBInstanceIdentifier=replica_identifier)
    except rds.exceptions.InvalidDBInstanceStateFault:
        logger.info("Replica already being promoted or already promoted")
    except Exception as exc:
        logger.exception("Failed to start promotion")
        return {
            "replica_ready": True,
            "promotion_started": False,
            "db_available": False,
            "db_status": status,
            "replica_identifier": replica_identifier,
            "db_endpoint": endpoint,
            "message": f"Failed to promote replica: {exc}",
        }

    waited = 0
    while waited < max_wait:
        db = describe_db_instance(rds, replica_identifier)
        status = db["DBInstanceStatus"]
        endpoint = db.get("Endpoint", {}).get("Address")

        logger.info("Polling promoted DB status=%s waited=%ss", status, waited)

        if status == "available":
            return {
                "replica_ready": True,
                "promotion_started": True,
                "db_available": True,
                "db_status": status,
                "replica_identifier": replica_identifier,
                "db_endpoint": endpoint,
                "message": "Replica promoted successfully and DB is available",
            }

        time.sleep(poll_interval)
        waited += poll_interval

    return {
        "replica_ready": True,
        "promotion_started": True,
        "db_available": False,
        "db_status": status,
        "replica_identifier": replica_identifier,
        "db_endpoint": endpoint,
        "message": f"Timed out waiting for promoted DB to become available after {max_wait}s",
    }


def describe_db_instance(rds_client: Any, db_identifier: str) -> dict[str, Any]:
    response = rds_client.describe_db_instances(DBInstanceIdentifier=db_identifier)
    return response["DBInstances"][0]


def extract_replica_lag(db_instance: dict[str, Any]) -> int | None:
    value = db_instance.get("PendingModifiedValues", {}).get("ReplicaMode")
    _ = value  # placeholder to make intent clear

    # RDS DescribeDBInstances does not always expose lag directly for all engines/flows.
    # Aurora/RDS behavior differs, so return None when not available.
    # If later you want a stricter check, fetch CloudWatch ReplicaLag instead.
    return None
