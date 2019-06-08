#!/bin/bash
exec ssh -Y -A -p 10022 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@127.0.0.1
