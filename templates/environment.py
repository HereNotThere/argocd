import argparse
from jinja2 import Environment, BaseLoader
import yaml
from yaml import dump, Dumper
import os

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

  template_names = ('global', 'app-of-apps')

  for template_name in template_names:
    template_file = f'{args.templates}/{template_name}.j2'
    with open(template_file, 'r') as f:
      template_str = f.read()
    template = environment.from_string(template_str)
    values = template.render(params_str)


    destination = f'{args.destination}/{template_name}.yaml'
    with open(destination, 'w') as f:
        f.write(values)

run()