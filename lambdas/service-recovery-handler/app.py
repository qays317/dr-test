import logging
import os
import time
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    dr_region = os.environ["DR_REGION"]
    cluster_name = os.environ["ECS_CLUSTER_NAME"]
    service_name = os.environ["ECS_SERVICE_NAME"]
    desired_count = int(os.environ.get("DR_DESIRED_COUNT", "2"))
    poll_interval = int(os.environ.get("POLL_INTERVAL_SECONDS", "15"))
    max_wait = int(os.environ.get("MAX_WAIT_SECONDS", "900"))

    ecs = boto3.client("ecs", region_name=dr_region)

    logger.info(
        "Starting service recovery handler cluster=%s service=%s desired=%s region=%s",
        cluster_name,
        service_name,
        desired_count,
        dr_region,
    )

    try:
        ecs.update_service(
            cluster=cluster_name,
            service=service_name,
            desiredCount=desired_count,
        )
    except Exception as exc:
        logger.exception("Failed to update ECS service desired count")
        return {
            "ecs_scaled": False,
            "ecs_healthy": False,
            "cluster_name": cluster_name,
            "service_name": service_name,
            "desired_count": desired_count,
            "message": f"Failed to scale ECS service: {exc}",
        }

    waited = 0
    while waited < max_wait:
        service = describe_service(ecs, cluster_name, service_name)

        running_count = service["runningCount"]
        pending_count = service["pendingCount"]
        wanted_count = service["desiredCount"]
        deployments = service.get("deployments", [])
        rollout_ok = all(dep.get("rolloutState") in (None, "COMPLETED") for dep in deployments)

        logger.info(
            "Polling ECS service running=%s pending=%s desired=%s rollout_ok=%s waited=%ss",
            running_count,
            pending_count,
            wanted_count,
            rollout_ok,
            waited,
        )

        if running_count >= desired_count and pending_count == 0 and rollout_ok:
            return {
                "ecs_scaled": True,
                "ecs_healthy": True,
                "cluster_name": cluster_name,
                "service_name": service_name,
                "running_count": running_count,
                "desired_count": wanted_count,
                "message": "ECS service scaled and became healthy",
            }

        time.sleep(poll_interval)
        waited += poll_interval

    service = describe_service(ecs, cluster_name, service_name)
    return {
        "ecs_scaled": True,
        "ecs_healthy": False,
        "cluster_name": cluster_name,
        "service_name": service_name,
        "running_count": service["runningCount"],
        "desired_count": service["desiredCount"],
        "message": f"Timed out waiting for ECS service recovery after {max_wait}s",
    }


def describe_service(ecs_client: Any, cluster_name: str, service_name: str) -> dict[str, Any]:
    response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])

    failures = response.get("failures", [])
    if failures:
        raise RuntimeError(f"ECS describe_services failures: {failures}")

    services = response.get("services", [])
    if not services:
        raise RuntimeError(f"ECS service {service_name} not found in cluster {cluster_name}")

    return services[0]
