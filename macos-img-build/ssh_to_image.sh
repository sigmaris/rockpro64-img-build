#!/bin/bash
exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2200 root@127.0.0.1
