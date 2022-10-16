#!/usr/bin/env bash

yarn audit;
yarn lint;
yarn e2e;
yarn test;
yarn sonar-scanner:scan;
