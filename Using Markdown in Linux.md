---
title: Using Markdown in Linux
---


# Using Markdown in Linux

The purpose of this document is to use a program to make markdown sysntax, use a converter to create html content, upload md to github, upload HTML to LinkedIn. 

Links
    * https://linuxhint.com/convert-markdown-files-linux/
    * https://github.com/mundimark/awesome-markdown-editors
    * https://www.markdownguide.org/basic-syntax/


Steps: 
    
     * Download and install a markdown editor from https://github.com/mundimark/awesome-markdown-editors
     * Make a document.
     * Assumptions: 
       * You have git setup.
       * You have a LinkedIn account. 
     * For Linux Ubuntu : Convert the md file. 
       * Install Pandoc
            * sudo apt install pandoc
            * pandoc file.md -f markdown -t html -s -o file.html
                * Replace the input and output filenames. 
                * I choose pandoc because it can convert to other formats.
      * Save to github
        * Login into your github account. 
        * Switch to your Respository. 
        * Click on "Add File"
            * Choose the md file. 
      * Upload file to LinkedIn
        * Click on  "Add File"
                
                
                