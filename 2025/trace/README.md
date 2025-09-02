# trace

tiny HTTP request headers logger.

## usage

```bash
docker build -t localhost:5000/trace .
docker run --rm -p 3000:3000 -d --name trace localhost:5000/trace
curl -v http://localhost:3000/foo
docker logs trace
docker stop trace
docker save -o trace.tar localhost:5000/trace
docker rmi localhost:5000/trace
```
