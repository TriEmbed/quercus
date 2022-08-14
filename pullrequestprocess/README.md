## Pull Request How To
version 0.01

Here are the steps to follow to modify the TriEmbed Quercus project repository at https://github.com/TriEmbed/quercus


Ordinarily <branchname> name will be of the form issueN where N is the repo issue number being addressed by the commit.

The "fork" operation used on the github.com web site is used to make a copy of a repository to a user's personal account from some other repo collection. For the Quercus project "fork" means "copy from https://github.com/TriEmbed/<repo> to user's accunt".

The "clone" operation is used to create a heirarchy of repositories with the source of the clone being the "parent" of the newly created clone repository. So a "push" is intended to update a "parent" repository with changes to the "child clone" repository.

1. In https://github.com/TriEmbed/quercus use the "Fork" button to make a fork of the repository in your personal Github account. 
    1. If you see that the target repo name in your personal account has a hyphen and number it means you aleady have one or more forks. This can be a cause of confusion and mistakes. To avoid this use a different name in the text box before completing the fork. A better approach may be to always override the name with something meaningful such as "quercusPRhowto".
2. In your personal account use the "clone" button to create a local clone of the forked repository. The next several steps will all involve this local clone repo.
3. git branch <branchname>
4. git checkout <branchname>
5. git branch -a
6. Confirm asterisk line shows <branchname> as the current branch. This is the branch that will hold the specific changes related to issueN
7. Make changes to files: the "git add" and "git commit" stepsbelow will often be iterated as changes are applied, corrected, extended, etc. 
    1. To undo a git add use "git reset"
    2. To undo a git commit use "git commit --soft HEAD~n where n is 1 to undo the most recent commit, 2, to undo the most recent two commits, etc. Use "git log" to see the commits being erased.
    3. In the worst case:
        1. Make a fresh clone
        2. Make a branch and check it out in the fresh clone
        3. Copy/add/commit files to the fresh clone to keep it sane
8. git add <files>
    1. You can "git add <directory> to cause a git add of all the directory files (recursive over all subdirectory files too)
9. git commit -m "commit message" 
    1. The last commit should begin with the text "issueN" where N is the specific issue being resolved
    2. To see all the changes you've made in a branch use "git log". The "git status" command will not show any changes.
10. git push origin <branchname>:main
    1. SPECIAL NOTE: Out in the world the correct origin target might be "master" or possibly some other name instead of the "main" label used by the Quercus repo. You can see which is required by seeing what "HEAD" points too with the "branch -a" step above. Getting this mixed up is an unhappy situation (how to recover?)

Versions of this how-to that are designed for popular GUI interfaces to git/github welcome!
