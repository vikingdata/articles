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
         * Look at the html and determine if it looks good. 
         * We will NOT be uploading the file. 
         
      * Save to github
        * Login into your github account. 
        * Switch to your Respository. 
        * Click on "Add File"
            * Choose the md file. 
        * Record link to file.     
      * Put file on LinkedIn
        * Click on the Home button
        * Click on "Start a post"
        * Put in content and link to article. 

* * *
<a name=notepad></a>Notepad++
-----

Or using git to sve documents, and use notepad++

* Install natepad++ https://notepad-plus-plus.org/downloads/v8.7.4/
* Using md plugin https://notepad-plus-plus.org/downloads/v8.7.4/
    * Download ddl and put in c"\Program Files\Notepad++\plugins/
    * Go to "plugins", then "plugins admin"
        * Search for MarkdownViewer++, click on it, then install it.
    * Open up a markdwown file.
    * You should see an icon on the far right bar called "Toggle Markdown  Panel". Click on it while you
    have a Markdown file open. You can adjust the size of the viewer. 
* Open your git markdown file in notepad, then it looks good in the Markdown Panel in Notepad, upload it to
git. 
                