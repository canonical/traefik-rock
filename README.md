# traefik-rock

[![Build ROCK](https://github.com/canonical/traefik-rock/actions/workflows/build-rock.yaml/badge.svg)](https://github.com/canonical/traefik-rock/actions/workflows/build-rock.yaml)

Automation for building a ROCK for Traefik. Every fourth hour, the automation checks whether 
a new release has been cut in the upstream Traefik repo, and if so, creates a pull request with 
the new version info.

Once the PR gets merged, a new ROCK is built and published on ghcr.io/canonical/traefik.


# Manual verification:
```
rockcraft -v

skopeo --insecure-policy copy oci-archive:traefik_2.9.6_amd64.rock docker-daemon:trfk

docker run  --rm -p 8080:8080 trfk
```

cleanup:
`docker rmi -f trfk`