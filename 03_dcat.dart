//命令行程序 https://dart.cn/tutorials/server/cmdline

import 'dart:convert'; //解决字符集问题
import 'dart:io'; //exitCode用
import 'package:args/args.dart';

const lineNumber = 'line-number';
//字符串出现多次，用常量代替

void main(List<String> args) {
  exitCode = 0;

  final parser = ArgParser();

  parser.addFlag(lineNumber, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(args);
  final paths = argResults.rest; //获取剩余的参数
  //要显示的文件路径
  dcat(paths, showLineNumbers: argResults[lineNumber] as bool);
  //argResults[lineNumber]是字符串
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  //{bool showLineNumbers = false}一个独立unit单元，有初始值，可选参数
  //async 异步，开设新的时间线
  if (paths.isEmpty) {
    print('type exit to quit');
    while (true) {
      stdout.write('>> ');
      String? line = stdin.readLineSync(); //?表示line可能会不存在
      print('$line');
      //添加了一个简单的两位数的加减乘除功能

      RegExp regExp = RegExp('^.*[0-9]+([\+]|[-]|[\*]|[\/])[0-9]+.*\$');
      if (line != null && regExp.hasMatch(line)) {
        var m = RegExp('[0-9]+').allMatches(line);
        var num = [];
        m.forEach((e) {
          String sub = line.substring(e.start, e.end);
          num.add(int.parse(sub));
        });
        var match = RegExp('[\+]|[\-]|[\*]|[\/]').allMatches(line);
        int i = 0;
        String newLine = line;
        match.forEach((e) {
          var op = line.substring(e.start, e.end);
          var res;
          switch (op) {
            case '+':
              res = num[i] + num[i + 1];
              break;
            case '-':
              res = num[i] - num[i + 1];
              break;
            case '*':
              res = num[i] * num[i + 1];
              break;
            case '/':
              res = num[i] / num[i + 1];
              break;
          }
          i = i + 1;
          newLine = newLine.replaceFirst(
              RegExp('[0-9]+([\+]|[-]|[\*]|[\/])[0-9]+'), res.toString());
        });
        print('$newLine\n');
      } else {
        print('');
      }
      if (line?.toLowerCase() == 'exit') {
        print('bye.');
        break;
      }
    }
    //await stdin.pipe(stdout);//把标准输入通过管道传递到输出里面
    //stdin是输入流，没有截止的时候
    //stdout一直等待直到输入流传来了数据
  } else {
    for (final path in paths) {
      var lineNumber = 1;

      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          print(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
    //stderr 标准错误输出流
  } else {
    exitCode = 2;
  }
}
