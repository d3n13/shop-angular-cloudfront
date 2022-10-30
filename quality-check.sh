#!/usr/bin/env bash

yarn audit;
yarn lint;
yarn e2e;
yarn test;
set +e
yarn sonar-scanner:scan 2>/dev/null
