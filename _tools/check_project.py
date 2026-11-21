"""粗检：括号配平、JSON 文件可解析、节点与线索数量是否符合作业要求。"""
import json
import re
from pathlib import Path

root = Path(r"C:\Users\30778\Doubao\chats\2026-11-20\new-chat\FogArchive")
problems = []

for p in root.rglob("*.ets"):
    text = p.read_text(encoding="utf-8")
    for pair in ("{}", "()", "[]"):
        if text.count(pair[0]) != text.count(pair[1]):
            problems.append(f"{p.name}: {pair} 不配平 {text.count(pair[0])}/{text.count(pair[1])}")

for p in list(root.rglob("*.json5")) + list(root.rglob("*.json")):
    try:
        json.loads(p.read_text(encoding="utf-8"))
    except Exception as exc:
        problems.append(f"{p.name}: JSON 解析失败 {exc}")

data = (root / "entry/src/main/ets/data/StoryData.ets").read_text(encoding="utf-8")
node_count = len(re.findall(r"new StoryNode\(", data))
clue_count = len(re.findall(r"new Clue\(", data))
ending_count = len(re.findall(r"new Ending\(", data))
files = len(list((root / "entry/src/main/ets").rglob("*.ets")))

print(f"节点 {node_count} / 线索 {clue_count} / 结局 {ending_count} / ets 文件 {files}")
print("问题：")
print("\n".join(problems) if problems else "无")
