"""Compact operational status; never print model thinking or full tool payloads."""
import json
from datetime import datetime, timezone
from pathlib import Path

record = Path(__file__).parents[1]
state = json.loads((record / 'task-state.json').read_text(encoding='utf-8-sig'))
stream = record / state['active_stream']
tools = []
events = 0
terminal = None
if stream.exists():
    for line in stream.read_text(encoding='utf-8-sig', errors='replace').splitlines():
        try:
            event = json.loads(line)
        except (ValueError, TypeError):
            continue
        events += 1
        if event.get('type') == 'assistant':
            for block in event.get('message', {}).get('content', []):
                if block.get('type') == 'tool_use':
                    args = block.get('input', {})
                    path = args.get('file_path') or args.get('path') or ''
                    tools.append({'name': block.get('name'), 'file': str(path)[:220]})
        if event.get('type') == 'result':
            terminal = {k: event.get(k) for k in ['subtype', 'is_error', 'duration_ms', 'num_turns']}
previous = {}
monitor = record / 'monitor-state.json'
if monitor.exists():
    previous = json.loads(monitor.read_text(encoding='utf-8-sig'))
out = {'checked_at': datetime.now(timezone.utc).isoformat(),
       'session_id': state['session_id'], 'active_stream': state['active_stream'],
       'stream_bytes': stream.stat().st_size if stream.exists() else 0,
       'events': events, 'tool_calls': len(tools), 'recent_tools': tools[-5:],
       'new_tools': max(0, len(tools) - (previous.get('tool_calls', 0)
                      if previous.get('active_stream') == state['active_stream'] else 0)),
       'exit': (record / state['active_exit']).read_text(encoding='utf-8-sig').strip()
               if (record / state['active_exit']).exists() else None,
       'result': terminal}
monitor.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(out, ensure_ascii=False))
progress = record / 'progress.md'
if progress.exists():
    print('PROGRESS TAIL:\n' + '\n'.join(progress.read_text(encoding='utf-8-sig').splitlines()[-14:]))
