import argparse
from jinja2 import Environment, BaseLoader
import yaml
from yaml import dump, Dumper
import os

TEMPLATE_NAMES = tuple(dict.fromkeys([
      'global', 'app-of-apps', 'argocd', 'cert-manager', 'datadog',
      'external-secrets', 'external-dns', 'main-alb',
      'notification-service', 'notification-sendit',
      'app-registry-service', 'metrics-aggregator',
      'river-node', 'rpc-gateway', 'subgraph', 'xchain-monitor',
  ]))

GENERATED_FILE_WARNING_MESSAGE = """############### WARNING ####################
# This file is generated by the environment.py script. Do not edit this file directly.
# Instead, edit the corresponding template file in the templates directory and run the environment.py script.
"""

class MyDumper(Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(MyDumper, self).increase_indent(flow, False)

def to_yaml(data):
    return dump(data, Dumper=MyDumper)

environment = Environment(loader=BaseLoader)
environment.filters.update({'to_yaml': to_yaml })

def append_key_value(data, key, value):
    if not key in data:
      # set the key to the value on the dictionary
      data[key] = value
    return data
  
def parse_command_line():
    parser = argparse.ArgumentParser(description='Generate environment values.yaml')
    parser.add_argument('--params', required=True, help='Parameters file')
    parser.add_argument('--destination', required=True, help='Destination file')
    parser.add_argument('--templates', required=True, help='Templates dir')
    return parser.parse_args()

def run():

  args = parse_command_line()
  
  # delete the destination directory if it exists
  if os.path.exists(args.destination):
    os.system(f'rm -rf {args.destination}')
  os.makedirs(args.destination)

  with open(args.params, 'r') as f:
      params_str = yaml.load(f, Loader=yaml.FullLoader)

  def render_remplate(destination, template_file):
    # check if the template file exists
    if not os.path.exists(template_file):
      print(f'Template file {template_file} does not exist. Generating empty render file...')
      with open(destination, 'w') as f:
        f.write(GENERATED_FILE_WARNING_MESSAGE)
    else:
      with open(template_file, 'r') as f:
        template_str = f.read()
      template = environment.from_string(template_str)
      rendered = template.render(params_str)

      with open(destination, 'w') as f:
          f.write(f'{GENERATED_FILE_WARNING_MESSAGE}\n')
          f.write(rendered)

  for template_name in TEMPLATE_NAMES:
    try:
      destination = f'{args.destination}/{template_name}.yaml'
      template_file = f'{args.templates}/{template_name}.j2'
      print('rendering template', template_name)
      render_remplate(destination, template_file)
    except Exception as e:
      print(f'Error rendering template {template_name}: {e}')
      raise e
    

run()