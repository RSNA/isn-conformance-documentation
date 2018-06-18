#!/bin/sh

BASE=/Users/smm/Projects/Image-Sharing-Tools/sequoia/imaging-2018-d
TEST_PATH=xdstools2/src/main/webapp/toolkitx/testkit/tests

touch tests; rm tests
ln -s $BASE/$TEST_PATH .
