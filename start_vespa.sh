docker run --detach --name vespa --hostname vespa-container \
      --publish 8080:8080 --publish 19071:19071 \
        vespaengine/vespa
