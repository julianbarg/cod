# cod

A command line interface that helps you code your data in clear text.

## Design philosophy

1. **Non-destructive** coding
* Codes are stored *in* the file, but *can be removed*.
2. **Cleartext**
* All tools are designed for qualitative data in cleartext. Whenever possible, the tools make use of markdown features.
3. **Cleartext tags**
* All tags are inserted into the raw data in cleartext. 
4. **Fixed linewidth** assumed
* *Note*: All documents should be converted to fixed linewidth .txt or .md prior to coding.
* Fixed linewidth allows for the coding of specific sections/sentences through the use of commands such as ```grep```.
5. **Inline tags**
* Inline codes are inserted at the end of each line.
6. **Document tags**
* Document tags are inserted at the end of the document, but are otherwise equivalent to inline codes. Tools for inline codes can be reused for document tags.
7. **Time stamps**
* One iteration of coding uses one time stamp.
* Pause any time and continue where you left of by running the previous command without generating a new time stamp.
* Before you enter into a new iteration of coding, create a new time stamp by using the ```-n``` flag.
8. Tags use **underscore**
* Tags to not have spaces to allow for easy search from the command line.
9. **Pipe friendly**
* Use ```cod``` to filter by tag before you begin coding. 
* Or write your own commands and pipe a list of documents to code into ```cod```.
10. **YAML** coding system
* Create your own coding system.
* Save your coding system to a YAML file and change it as you go.
* Recode your existing codes from your iteration by using a pipe.
11. **Unique IDs**
* Create your own IDs or use hashes to refer to your documents when recoding.
