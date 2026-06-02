#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// 创建控制台并附加到当前进程
void CreateAndAttachConsole();

// 获取命令行参数
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_UTILS_H_
