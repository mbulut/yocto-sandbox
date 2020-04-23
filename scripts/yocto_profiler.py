#!/usr/bin/python3

import argparse
import json
import matplotlib.pyplot as plt
import numpy as np
import re

from datetime import datetime, timedelta
from pathlib import Path


def collect_recipe_stats(logfile):
    recipe_stats=dict()
    event_pattern = re.compile("\\[(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{3})Z\\] NOTE: recipe (.+): task do_(.+): (\\bStarted\\b|\\bSucceeded\\b)")
    for time,recipe,task,action in event_pattern.findall(logfile.read()):
        recipe = re.sub("\\+gitAUTOINC\\+[0-9A-Fa-f]{10}", "", recipe)
        rs = recipe_stats.get(recipe, dict())
        stamp = datetime.timestamp(datetime.strptime(time, "%Y-%m-%dT%H:%M:%S.%f"))
        ts = rs.get(task, stamp)
        if action == "Succeeded":
            ts = stamp - ts
        rs.update({task : ts})
        recipe_stats.update({recipe : rs})
    return recipe_stats


def get_overall_task_durations(recipe_stats, filter):
    task_durations=dict()
    for _,tasks in recipe_stats.items():
        for task,duration in tasks.items():
            if filter and filter not in task:
                continue
            td = task_durations.get(task, 0)
            task_durations.update({task : td+duration})
    return task_durations


def get_overall_recipe_durations(recipe_stats, filter):
    recipe_durations=dict()
    for recipe,tasks in recipe_stats.items():
        if filter and filter not in recipe:
            continue
        rd = 0
        for duration in tasks.values():
            rd += duration
        recipe_durations.update({recipe : rd})
    return recipe_durations


def generate_plot(logfile, recipes, filter):
    recipe_stats = collect_recipe_stats(logfile)
    if recipes:
        duration_map = get_overall_recipe_durations(recipe_stats, filter)
    else:
        duration_map = get_overall_task_durations(recipe_stats, filter)
    tasks = list()
    durations = list()
    total_duration = sum(duration_map.values())
    { tasks.append(t): d for t, d in sorted(duration_map.items(), key=lambda item: item[1]) }
    { durations.append(duration_map[t]*100/total_duration): d for t, d in sorted(duration_map.items(), key=lambda item: item[1]) }
    y_pos = np.arange(len(tasks))
    plt.barh(y_pos, durations, align="center", alpha=0.5)
    plt.yticks(y_pos, tasks)
    plt.xlabel("Distribution [%]")
    if recipes:
        plt.ylabel("Recipe")
        plt.title("Distribution of Yocto Recipe Build Durations")
    else:
        plt.ylabel("Task")
        plt.title("Distribution of Yocto Build Task Durations")
    plt.grid()
    plt.show()


def generate_json(logfile, recipes, filter):
    recipe_stats = collect_recipe_stats(logfile)
    if recipes:
        print(json.dumps(get_overall_recipe_durations(recipe_stats, filter), indent=2))
    else:
        print(json.dumps(get_overall_task_durations(recipe_stats, filter), indent=2))


def generate_text(logfile, recipes, filter):
    recipe_stats = collect_recipe_stats(logfile)
    if recipes:
        duration_map = get_overall_recipe_durations(recipe_stats, filter)
    else:
        duration_map = get_overall_task_durations(recipe_stats, filter)
    pad = max([len(k) for k in duration_map.keys()]) + 1
    fmt = "{{:{}}}: {{}}".format(pad)
    { print(fmt.format(t, timedelta(seconds=duration_map[t]))): d for t, d in sorted(duration_map.items(), key=lambda item: item[1], reverse=True) }


def get_args():
    parser = argparse.ArgumentParser()
    parser.description = "a tool for profiling distribution of times elapsed in different bitbake tasks"
    parser.add_help

    parser.add_argument("file", type=str, help="path to bitbake console log")

    group = parser.add_mutually_exclusive_group()
    group.add_argument("-j", "--json", action="store_true", help="output profile summary as JSON")
    group.add_argument("-p", "--plot", action="store_true", help="plot profile data on screen")

    parser.add_argument("-r", "--recipes", action="store_true", help="profile recipe runtimes instead of task runtimes")
    parser.add_argument("-f", "--filter", type=str, help="include only tasks/recipes matching FILTER")
    parser.add_argument("-v", "--verbosity", action="count", default=0)

    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()
    with Path(args.file).open(mode="r") as logfile:
        if args.plot:
            generate_plot(logfile, args.recipes, args.filter)
        elif args.json:
            generate_json(logfile, args.recipes, args.filter)
        else:
            generate_text(logfile, args.recipes, args.filter)
