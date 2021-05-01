#!/bin/sh
export PATH="$HOME/.pub-cache/bin:$PATH"
cd third-party/migchat-proto
protoc migchat.proto --dart_out=grpc:../../lib/proto/generated
cd ../..