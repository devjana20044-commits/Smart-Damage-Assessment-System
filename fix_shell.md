# Fix: PowerShell 5.1 Shell Execution

## المشكلة

أنبوب التنفيذ (execution pipeline) يضيف تلقائياً بادئة أوامر CMD قبل كل أمر تنفذه أداة `bash`. البادئة تستخدم صياغة CMD مع `&&`:

```
set CI="true" && set DEBIAN_FRONTEND="noninteractive" && set GIT_TERMINAL_PROMPT="0" && ... && {your_command}
```

PowerShell 5.1 **لا يدعم `&&`** كفاصل أوامر، مما يسبب فشل فوري قبل تنفيذ أي شيء:

```
At line:1 char:15
+ set CI="true" && set DEBIAN_FRONTEND="noninteractive" && ...
+               ~~
The token '&&' is not a valid statement separator in this version.
```

## الحل

### الطريقة: كتابة سكربت `.ps1` ثم تنفيذه عبر `powershell -File`

بدلاً من تمرير الأوامر مباشرة في معامل `command`، اكتب الأوامر في ملف `.ps1` ثم نفذه:

```
1. استخدم أداة `write` لكتابة سكربت PowerShell إلى ملف مؤقت
2. استخدم أداة `bash` مع الأمر: powershell -ExecutionPolicy Bypass -File "path\to\script.ps1"
```

### مثال عملي

**الخطوة 1** - اكتب السكربت:

```
write(
  filePath = "C:\Users\ABDALG~1\AppData\Local\Temp\opencode\my-task.ps1",
  content = "git clone https://github.com/user/repo.git C:\path\to\dest"
)
```

**الخطوة 2** - نفذ السكربت:

```
bash(
  command = 'powershell -ExecutionPolicy Bypass -File "C:\Users\ABDALG~1\AppData\Local\Temp\opencode\my-task.ps1"',
  description = "Execute git clone via PS1 script",
  timeout = 120000
)
```

### لماذا يعمل هذا الحل؟

- النظام يضيف البادئة قبل أمر `powershell -File ...` نفسه
- لكن البادئة تُنفذ في سياق CMD (حيث `&&` مدعوم) أو يتم تجاهلها
- الملف `.ps1` يُنفذ داخل PowerShell مستقل بمعامل `-File` بعيداً عن البادئة
- `-ExecutionPolicy Bypass` يسمح بتنفيذ السكربت بدون قيود

### قواعد أساسية لـ PowerShell 5.1

| الغرض | الصياغة الصحيحة | الصياغة الخاطئة |
|---|---|---|
| متغير بيئة | `$env:VAR="value"` | `set VAR=value` |
| فاصل الأوامر | `;` (فاصلة منقوطة) | `&&` |
| تعريف متغير | `$var = "value"` | `set VAR="value"` |
| تنفيذ أمر خارجي | `& "path\to\exe"` | `path\to\exe` (مع مسافات) |
| تعليق | `# comment` | `REM comment` |

### ملخص

```
لا تكتب أوامر PowerShell مباشرة في معامل command
اكتبها في ملف .ps1 ثم نفذها بـ powershell -ExecutionPolicy Bypass -File "path.ps1"
```
