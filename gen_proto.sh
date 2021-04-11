#!/bin/sh
export PATH="$PATH:$HOME/.pub-cache/bin"
cd third-party/migchat-proto
protoc migchat.proto --dart_out=grpc:../../lib/proto/generated
cd ../..