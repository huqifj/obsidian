" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk
" I like using H and L for beginningend of line
nmap H ^
nmap L $
" Quickly remove search highlights
nmap F9 nohl

" Yank to system clipboard
set clipboard=unnamed

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand appgo-back
nmap C-o back
exmap forward obcommand appgo-forward
nmap C-i forward