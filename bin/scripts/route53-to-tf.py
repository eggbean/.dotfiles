#!/usr/bin/env python3
#
# Copyright (c) 2020 Brenden Matthews <brenden@brndn.io> under the MIT license
# at https://opensource.org/licenses/MIT
#
# This script converts existing Route53 records into Terraform HCL. I created
# this for a one-off job. The script uses the AWS CLI to fetch Route53 info,
# and prints the corresponding TF code to stdout.
#
# Example usage:
#
#   $ ./route53-to-tf.py Z01628355IFGP8944TLS > route53.tf
#   $ echo 'set -ex' > import.sh
#   $ grep '# $ terraform import' route53.tf | sed 's/^# $ //g' >> import.sh
#   $ sh import.sh
#
# Use at your own risk. Be very careful and double check the records after
# using the tool. Terraform and Route53 have some weird behaviour, specifically
# with TXT records and how they handle quotes.
#
# MAKE SURE IT'S RIGHT BEFORE RUNNING 'terraform apply'.
#

import subprocess
import argparse
import json
import pprint
from string import Template

parser = argparse.ArgumentParser(
    description='Convert AWS Route53 records into Terraform code')
parser.add_argument('zones', metavar='ZoneID', type=str, nargs='+',
                    help='Zone ID to import')

args = parser.parse_args()


def to_tf_name(name):
    return name.replace('_', '').replace('.', '_').strip('_')


def print_zone(zone):
    template = Template("""
# $$ terraform import aws_route53_zone.$tf_name ${zone_id}
resource "aws_route53_zone" "$tf_name" {
  name = "$name"
}""")
    tf_name = to_tf_name(zone['HostedZone']['Name'])
    t = template.substitute(
        zone_id=zone['HostedZone']['Id'],
        tf_name=tf_name,
        name=zone['HostedZone']['Name'].strip('.')  # Trailing . not required
    )
    print(t)
    return tf_name


def print_as_tf(zone_id, zone_tf_name, record):
    template = Template("""
# $$ terraform import aws_route53_record.${type}_${tf_name} ${zone_id}_${name}_${type}
resource "aws_route53_record" "${type}_${tf_name}" {
  zone_id = aws_route53_zone.$zone_tf_name.zone_id
  name    = "$name"
  type    = "$type"
  ttl     = "$ttl"
  records = [$records]
}""")
    values = (v['Value'].replace("\\", "\\\\").replace("\"", "\\\"").strip("\\\"").rstrip("\\\"")
              for v in record['ResourceRecords'])
    values = (f"\"{v}\"" for v in values)
    t = template.substitute(
        tf_name=to_tf_name(record['Name']),
        zone_tf_name=zone_tf_name,
        zone_id=zone_id,
        name=record['Name'].strip('.'),  # Trailing . not required
        ttl=record['TTL'],
        type=record['Type'],
        records=','.join(values)
    )
    print(t)


for zone in args.zones:
    result = subprocess.run(['aws', 'route53', 'get-hosted-zone', '--output', 'json',
                             '--id', zone], stdout=subprocess.PIPE)
    result.check_returncode()
    zone_data = json.loads(result.stdout)
    zone_tf_name = print_zone(zone_data)

    result = subprocess.run(['aws', 'route53', 'list-resource-record-sets', '--output', 'json',
                             '--hosted-zone-id', zone], stdout=subprocess.PIPE)
    result.check_returncode()
    record_data = json.loads(result.stdout)
    if 'ResourceRecordSets' in record_data:
        for record in record_data['ResourceRecordSets']:
            print_as_tf(zone, zone_tf_name, record)
