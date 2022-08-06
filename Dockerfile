# Copyright 2019 The GCR Cleaner Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=$BUILDPLATFORM golang:1.18 AS builder

ARG SERVICE

ENV GO111MODULE=on \
  GOPROXY=https://proxy.golang.org,direct \
  CGO_ENABLED=0

WORKDIR /src
COPY . .

RUN go mod download

RUN go build \
  -a \
  -trimpath \
  -ldflags "-s -w -extldflags=-static" \
  -o /bin/gcrcleaner \
  ./cmd/${SERVICE}

RUN strip -s /bin/gcrcleaner



FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /bin/gcrcleaner /bin/gcrcleaner

ENV PORT 8080

ENTRYPOINT ["/bin/gcrcleaner"]
