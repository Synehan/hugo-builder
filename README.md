# hugo-builder

![](https://github.com/synehan/hugo-builder/workflows/Docker%20Image%20CI/badge.svg)

Auto-trigger Docker Build for [Hugo](https://gohugo.io) when new release is annonced.

[![dockeri.co](https://dockeri.co/image/synehan/hugo-builder)](https://hub.docker.com/r/synehan/hugo-builder)

## NOTES

The latest docker tag is the latest release version (https://github.com/gohugoio/hugo/releases/latest)

Please avoid to use `latest` tag for any production deployment. Tag with right version is the proper way, such as `synehan/hugo-builder:0.70.0`

### Github Repo

https://github.com/synehan/hugo-builder

### Docker image tags

https://hub.docker.com/r/synehan/hugo-builder/tags

## Usage

For help:

```bash
docker run --rm synehan/hugo-builder
```

If you want to build your Hugo website located in the current dir:

```bash
docker run --rm -v $(pwd):/build -w /build synehan/hugo-builder deploy --maxDeletes -1
```

### In GCP Cloud Build pipeline

Create a cloudbuild file like:

```yaml
steps:
  - name: 'synehan/hugo-builder:0.70.0'
    args: ['--minify']
  - name: 'synehan/hugo-builder:0.70.0'
    args: ['deploy', '--maxDeletes', '-1']
```

## Credits

- Borrowed from [docker-pluto](https://github.com/renault-digital/docker-pluto).
- Original works from https://github.com/alpine-docker/pluto.

