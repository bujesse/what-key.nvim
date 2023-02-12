command! -nargs=0 WhatKeyShow lua require('what-key.view').show()
command! -nargs=0 WhatKeyHide lua require('what-key.view').hide()
command! -nargs=0 WhatKeyToggle lua require('what-key.view').toggle()
