# Vim Mappings to move lines


The following mappings in your **vimrc** provide a quick way to move lines of text up or down. The mappings work in normal, insert and visual modes, allowing you to move the current line, or a selected block of lines.

```
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

```

In normal mode or in insert mode, press Alt-j to move the current line down, or press Alt-k to move the current line up.

After visually selecting a block of lines (for example, by pressing `V` then moving the cursor down), press Alt-j to move the whole block down, or press Alt-k to move the block up.

### Explanation

The command `:m .+1` (which can be abbreviated to `:m+`) moves the current line to after line number `.+1` (current line number + 1). That is, the current line is moved down one line.

The command `:m .-2` (which can be abbreviated to `:m-2`) moves the current line to after line number `.-2` (current line number − 2). That is, the current line is moved up one line.

After visually selecting some lines, entering `:m '>+1` moves the selected lines to after line number `'>+1` (one line after the last selected line; `'>` is a mark assigned by Vim to identify the selection end). That is, the block of selected lines is moved down one line.

The `==` re-indents the line to suit its new position. For the visual-mode mappings, `gv` reselects the last visual block and `=` re-indents that block.