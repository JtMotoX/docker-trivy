# docker-trivy

## Description
This will perform a vulnerability scan of all images of currently running containers.  The schedule is defined in the [crontab](/build/crontab) file. It is recommended to have the log files pushed into a logging tool such as Splunk for analysis and alerting.

## Instructions
1. Determine the host docker gid: `stat -c '%g' /var/run/docker.sock`
1. Update the [.env](/.env) file with the DOCKER_GID
1. Run `docker-compose down && docker-compose up --build -d && docker-compose logs -f`
1. Press `CTRL+C` to stop tailing the container logs (container will continue to run)
1. The scan logs will be stored in the [scan-logs](/scan-logs) directory

NOTE: The scans run on a schedule, however, if you want to trigger a manual scan, execute `docker-compose run --rm trivy /scripts/scan-all.sh`.

## Parsing Logs Examples

```bash
> cat ./scan-logs/jtmotox/docker-trivy:local.json | jq -r '.Results[].Vulnerabilities[] | .Severity + "~" + .PkgName + "~Fixed in " + .FixedVersion + "~" + .VulnerabilityID' | sort | uniq | column -t -s '~'

LOW      github.com/aws/aws-sdk-go  Fixed in            CVE-2020-8912
LOW      libcurl                    Fixed in 7.83.1-r3  CVE-2022-35252
MEDIUM   github.com/aws/aws-sdk-go  Fixed in            CVE-2020-8911
MEDIUM   helm.sh/helm/v3            Fixed in 3.9.4      CVE-2022-36055
UNKNOWN  github.com/aws/aws-sdk-go  Fixed in            GHSA-7f33-f4f5-xwgw
UNKNOWN  github.com/aws/aws-sdk-go  Fixed in            GHSA-f5pg-7wfw-84q9
UNKNOWN  helm.sh/helm/v3            Fixed in 3.9.4      GHSA-7hfp-qfw3-5jxh
```
