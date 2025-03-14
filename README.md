# docker-trivy

## Description
This will perform a vulnerability scan of all images of currently running containers.  The schedule is defined in the [crontab](/build/crontab) file. It is recommended to have the log files pushed into a logging tool such as Splunk (will need to set TRUNCATE=0 in props.conf) for analysis and alerting.

## Instructions
1. Copy the [.env-sample](/.env-sample) file to [.env](/.env)
2. Run `docker-compose down && docker-compose up --build -d && docker-compose logs -f`
1. Press `CTRL+C` to stop tailing the container logs (container will continue to run)
1. The scan logs will be stored in the [scan-logs](/scan-logs) directory

## Manual Scan
NOTE: The scans run on a schedule, however, you can trigger a manual scan. Below are some examples.
- `docker-compose run --rm trivy /scripts/scan.sh jtmotox/docker-trivy:local`
- `docker-compose run --rm trivy /scripts/scan-all.sh`
- `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/aquasecurity/trivy:latest image nginx:latest`

## Parsing Logs Examples

```bash
> cat ./scan-logs/combined/1730003018_jtmotox+docker-trivy:local.json | jq -r '.Results[].Vulnerabilities[] | .Severity + "~" + .PkgName + "~Fixed in " + .FixedVersion + "~" + .VulnerabilityID' | sort | uniq | column -t -s '~'

LOW      github.com/aws/aws-sdk-go  Fixed in            CVE-2020-8912
LOW      libcurl                    Fixed in 7.83.1-r3  CVE-2022-35252
MEDIUM   github.com/aws/aws-sdk-go  Fixed in            CVE-2020-8911
MEDIUM   helm.sh/helm/v3            Fixed in 3.9.4      CVE-2022-36055
UNKNOWN  github.com/aws/aws-sdk-go  Fixed in            GHSA-7f33-f4f5-xwgw
UNKNOWN  github.com/aws/aws-sdk-go  Fixed in            GHSA-f5pg-7wfw-84q9
UNKNOWN  helm.sh/helm/v3            Fixed in 3.9.4      GHSA-7hfp-qfw3-5jxh
```

```bash
> find ./scan-logs/combined/ -name "*.json" | while read -r LOGFILE; do echo "${LOGFILE}"; cat "${LOGFILE}" | jq -r '.Results[] | select(.Vulnerabilities) | .Vulnerabilities[] | .Severity + "~" + .PkgName + "~Fixed in " + .FixedVersion + "~" + .VulnerabilityID' | grep -v -E '^(MEDIUM|LOW|UNKNOWN)' | sort | uniq; done | column -t -s '~'

./scan-logs/mariadb:10.7.json
HIGH        github.com/opencontainers/runc  Fixed in v1.1.2                 CVE-2022-29162
HIGH        libssl1.1                       Fixed in 1.1.1f-1ubuntu2.12     CVE-2022-0778
HIGH        openssl                         Fixed in 1.1.1f-1ubuntu2.12     CVE-2022-0778
./scan-logs/nginx:1.23-alpine.json
CRITICAL    curl                            Fixed in 7.83.1-r2              CVE-2022-32207
CRITICAL    libcurl                         Fixed in 7.83.1-r2              CVE-2022-32207
CRITICAL    zlib                            Fixed in 1.2.12-r2              CVE-2022-37434
HIGH        busybox                         Fixed in 1.35.0-r15             CVE-2022-30065
HIGH        ssl_client                      Fixed in 1.35.0-r15             CVE-2022-30065
```

```bash
find ./scan-logs/combined/ -name "*.json" | while read -r LOGFILE; do cat "${LOGFILE}" | jq -r '.Results[] | select(.Vulnerabilities) | .Vulnerabilities[] | .Severity + "~" + .PkgName + "~Fixed in " + .FixedVersion + "~" + .VulnerabilityID' | grep -v -E '^(MEDIUM|LOW|UNKNOWN)' | wc -l | xargs -I {} echo "{} ${LOGFILE}"; done | sort -rn

226 ./scan-logs/combined/1730000712_clp-prd-clp-web.json
217 ./scan-logs/combined/1730000508_clp-dev-clp-web.json
214 ./scan-logs/combined/1730002242_web-apache.json
207 ./scan-logs/combined/1730000994_jc21+nginx-proxy-manager:latest.json
...
```