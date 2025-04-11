" 解决鼠标右键不能使用问题
if has('mouse')
  set mouse-=a
endif

" 解决插入模式下delete/backspce键失效问题
set backspace=2

" 解决方向键无法使用的问题. 可能会导致退出vim后，编辑的文本内容仍保留在屏幕
" set term=builtin_ansi
" 也可以 echo "export TERM=xterm" >> ~/.bashrc 
set term=xterm

" 设置编码为utf-8,解决中文字符乱码问题
set encoding=utf-8
