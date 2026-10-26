"""Standalone panel entry; load its package under a unique name."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path
from uuid import uuid4

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    for flag in ('data', 'out'):
        parser.add_argument('--' + flag, type=Path, required=True)
    parser.add_argument('--style', type=Path)
    args = parser.parse_args()
    target = Path(__file__).resolve().parents[1]
    spec = json.loads((target / 'spec.json').read_text(encoding='utf-8'))
    style = spec['style'] | (json.loads(args.style.read_text(encoding='utf-8')) if args.style else {})
    name = 'panel_' + uuid4().hex
    package_spec = importlib.util.spec_from_file_location(
        name, target / 'code/__init__.py', submodule_search_locations=[str(target / 'code')])
    package = importlib.util.module_from_spec(package_spec)
    sys.modules[name] = package
    package_spec.loader.exec_module(package)
    panel_spec = importlib.util.spec_from_file_location(name + '.panel', target / 'code/panel.py')
    panel = importlib.util.module_from_spec(panel_spec)
    sys.modules[name + '.panel'] = panel
    panel_spec.loader.exec_module(panel)
    tables = {key: pd.read_csv(args.data / f"{table['interface']}.csv") for key, table in spec['tables'].items()}
    matplotlib.rcParams.update({'pdf.fonttype': 42, 'svg.fonttype': 'none'})
    fig = plt.figure(figsize=(style['width_in'], style['height_in']), dpi=style['dpi'])
    panel.draw(fig, style['rect'], tables, style)
    args.out.mkdir(parents=True, exist_ok=True)
    for extension in ('png', 'pdf', 'svg'):
        fig.savefig(args.out / f'figure.{extension}', format=extension,
                    dpi=style['dpi'], bbox_inches=None, facecolor='white')
    plt.close(fig)


if __name__ == '__main__':
    main()
