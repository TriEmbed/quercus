# Contributing to the Project

We would love for you to contribute to our project and help make it even better than it is today!
As a contributor, here are the guidelines we would like you to follow:

 - [Code of Conduct](#coc)
 - [Question or Problem?](#question)
 - [Issues and Bugs](#issue)
 - [Feature Requests](#feature)
 - [Submission Guidelines](#submit)  
   -- [Pull Requests](#submit-pr)
 - [Coding Rules](#rules)
 - [Commit Message Guidelines](#commit)
 - [Signing the CLA](#cla)


## <a name="coc"></a> Code of Conduct

Help us keep Quercus open and inclusive.
Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).


## <a name="question"></a> Got a Question or Problem?

For the time being, we will answer general support questions that are submitted using the **Support Question** [issue template](https://github.com/triembed/quercus/issues/new/choose).
The team reserves the right to alter this method of support as needed. Updates will be available here.

Live realtime chat for support issues is not available at this time.

## <a name="issue"></a> Found a Bug?

If you find a bug in the source code, you can help us by [submitting a bug report](#submit-issue) to our [GitHub Repository](https://github.com/triembed/quercus).
Even better, you can [submit a Pull Request](#submit-pr) with a fix.


## <a name="feature"></a> Missing a Feature?
You can *request* a new feature by [submitting an issue](#submit-issue) to our GitHub Repository.
If you would like to *implement* a new feature, please consider the size of the change in order to determine the right steps to proceed:

* For a **Major Feature**, first open a Feature Request issue and outline your proposal so that it can be discussed.
  This process allows us to better coordinate our efforts, prevent duplication of work, and help you to craft the change so that it is successfully accepted into the project.

  **Note**: Adding a new topic to the documentation, or significantly re-writing a topic, counts as a major feature.

* **Small Features** can be crafted and directly [submitted as a Pull Request](#submit-pr).


## <a name="submit"></a> Submission Guidelines


### <a name="submit-issue"></a> Submitting an Issue

Before you submit an bug report or a feature request, please search the issue tracker. An issue for your problem might
already exist and the discussion might inform you of workarounds readily available.

[ **TODO: Is the following okay, or are there more or more-specific instructions needed?** ]
We want to fix all the issues as soon as possible, but before fixing a bug, we need to reproduce and confirm it.
In order to reproduce bugs, we require that you provide a minimal reproduction.
Having a minimal reproducible scenario gives us a wealth of important information without going back and forth to you with additional questions.

A minimal reproduction allows us to quickly confirm a bug (or point out a coding problem) as well as confirm that we are fixing the right problem.

We require a minimal reproduction to save maintainers' time and ultimately be able to fix more bugs.
Often, developers find coding or wiring problems themselves while preparing a minimal reproduction.
We understand that sometimes it might be hard to extract essential bits of code from a larger codebase but we really need to isolate the problem before we can fix it.

Unfortunately, we are not able to investigate / fix bugs without a minimal reproduction, so if we don't hear back from you, we are going to close an issue that doesn't have enough info to be reproduced.

You can file new issues by selecting from our [issue templates](https://github.com/triembed/quercus/issues/new/choose).


### <a name="submit-pr"></a> Submitting a Pull Request (PR)

Submitting a Pull Request is how you provide proposed updates for the repository, to fix a bug or add a feature.

Before you submit your Pull Request (PR) consider the following guidelines:

1. Search [existing pull requests](https://github.com/triembed/quercus/pulls) for an open or closed PR that relates to your submission.
   You don't want to duplicate existing efforts.

2. Be sure that an issue describes the problem you're fixing, or documents the design for the feature you'd like to add.
   Discussing the design upfront helps to ensure that we're ready to accept your work.

3. If there is not an issue already covering your proposed contribution, create it before you do anything else!
   You'll need the issue number to create your pull request.

4. Please review our [Contributor License Agreement (CLA)](#cla) before sending PRs.
   We cannot accept code without an acknowledged CLA.
   Make sure you author all contributed Git commits with the email address associated with your CLA signature.

5. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the triembed/quercus repo.

6. [Clone](https://docs.github.com/en/get-started/quickstart/fork-a-repo#cloning-your-forked-repository) your forked repository to copy the files to your system where you can update them.
   From the command line this might look like one of these examples. The link gives detailed instructions.

    ```shell
    $ git clone https://github.com/YOUR-NAME/quercus
    ```
   or (using SSH):
    ```shell
    $ git clone git@github.com:YOUR-NAME/quercus.git
    ```

7. In your cloned repository, create a new branch for your changes:  (`issueN` is the issue number from above, e.g., `issue123`)

     ```shell
     git checkout -b issueN-branch main
     ```

6. Create your patch, **including appropriate test cases** in this new branch.

7. Follow our [Coding Rules](#rules).

8. Run the full quercus test suite, as described in the [developer documentation][dev-doc], and ensure that all tests pass.

9. Commit your changes using a descriptive commit message that follows our [commit message conventions](#commit).
   Adherence to these conventions is necessary because release notes are automatically generated from these messages.

     ```shell
     git commit --all -m "issueN: <commit message here>"
     ```
   Note: the optional commit `-a` command line option will automatically "add" and "rm" edited files.

10. Push your branch to your forked repo in GitHub:

    ```shell
    git push origin issueN-branch
    ```

11. In GitHub, send a pull request to `quercus:main`.

### Reviewing a Pull Request

The Quercus team reserves the right not to accept pull requests from community members who haven't been good citizens of the community. 
Such behavior includes not following the [code of conduct](CODE_OF_CONDUCT.md) and applies within or outside of our managed channels.

#### Addressing review feedback

If we ask for changes via code reviews then:

1. Make the required updates to the code.

2. Re-run the Quercus test suites to ensure tests are still passing.

3. Create a fixup commit and push to your GitHub repository (this will update your Pull Request):

    ```shell
    git commit --all --fixup HEAD
    git push
    ```

    For more info on working with fixup commits see [here](https://github.com/angular/angular/blob/main/docs/FIXUP_COMMITS.md).

That's it! Thank you for your contribution!


##### Updating the commit message

A reviewer might often suggest changes to a commit message (for example, to add more context for a change or adhere to our [commit message guidelines](#commit)).
In order to update the commit message of the last commit on your branch:

1. Check out your branch:

    ```shell
    git checkout issueN-branch
    ```

2. Amend the last commit and modify the commit message:

    ```shell
    git commit --amend
    ```

3. Push to your GitHub repository:

    ```shell
    git push --force-with-lease
    ```

> NOTE:<br />
> If you need to update the commit message of an earlier commit, you can use `git rebase` in interactive mode.
> See the [git docs](https://git-scm.com/docs/git-rebase#_interactive_mode) for more details.


#### After your pull request is merged

After your pull request is merged, you can safely delete your branch and pull the changes from the main (upstream) repository:

* Delete the remote branch on GitHub either through the GitHub web UI or your local shell as follows:

    ```shell
    git push origin --delete issueN-branch
    ```

* Check out the main branch:

    ```shell
    git checkout main -f
    ```

* Delete the local branch:

    ```shell
    git branch -D issueN-branch
    ```

* Update your local `main` with the latest upstream version: (See [here](https://docs.github.com/en/get-started/quickstart/fork-a-repo#configuring-git-to-sync-your-fork-with-the-original-repository) for info on configuring upstream.)

    ```shell
    git pull --ff upstream main
    ```


## <a name="rules"></a> Coding Rules
To ensure consistency throughout the source code, keep these rules in mind as you are working:

* All features or bug fixes **must be tested** by one or more specs (unit-tests).
* All public API methods **must be documented**.
* We follow [Google's JavaScript Style Guide][js-style-guide], but wrap all code at **100 characters**.

   An automated formatter is available, see [DEVELOPER.md](docs/DEVELOPER.md#clang-format).


## <a name="commit"></a> Commit Message Format

*This specification is inspired by and supersedes the [AngularJS commit message format][commit-message-format].*

We have very precise rules over how our Git commit messages must be formatted.
This format leads to **easier to read commit history**.

Each commit message consists of a **header**, a **body**, and a **footer**.

You can specify `-F filename` as an argument to the `git commit` command to pull the commit message from a file that you've prepared ahead of time.
Be careful not to accidentally commit the comment file into the repository! :-)


    ```
    <header>
    <BLANK LINE>
    <body>
    <BLANK LINE>
    <footer>
    ```

The `header` is mandatory and must conform to the [Commit Message Header](#commit-header) format.

The `body` is mandatory for all commits except for those of type "docs".
When the body is present it must be at least 20 characters long and must conform to the [Commit Message Body](#commit-body) format.

The `footer` is optional. The [Commit Message Footer](#commit-footer) format describes what the footer is used for and the structure it must have.


#### <a name="commit-header"></a>Commit Message Header

```
<type>(<scope>): <short summary>
  │       │             │
  │       │             └─⫸ Summary in present tense. Not capitalized. No period at the end.
  │       │
  │       └─⫸ Commit Scope: animations|bazel|benchpress|common|compiler|compiler-cli|core|
  │                          elements|forms|http|language-service|localize|platform-browser|
  │                          platform-browser-dynamic|platform-server|router|service-worker|
  │                          upgrade|zone.js|packaging|changelog|docs-infra|migrations|ngcc|ve|
  │                          devtools
  │
  └─⫸ Commit Type: build|ci|docs|feat|fix|perf|refactor|test
```

The `<type>` and `<summary>` fields are mandatory, the `(<scope>)` field is optional.


##### Type

Must be one of the following:

* **build**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
* **ci**: Changes to our CI configuration files and scripts (examples: CircleCi, SauceLabs)
* **docs**: Documentation only changes
* **feat**: A new feature
* **fix**: A bug fix
* **perf**: A code change that improves performance
* **refactor**: A code change that neither fixes a bug nor adds a feature
* **test**: Adding missing tests or correcting existing tests


##### Scope
The scope should be the name of the npm package affected (as perceived by the person reading the changelog generated from commit messages).

The following is the list of supported scopes:

* `common`

There are currently a few exceptions to the "use package name" rule:

* `packaging`: used for changes that change the npm package layout in all of our packages, e.g. public path changes, package.json changes done to all packages, d.ts file/format changes, changes to bundles, etc.

* `changelog`: used for updating the release notes in CHANGELOG.md

* `dev-infra`: used for dev-infra related changes within the directories /scripts and /tools

* `docs-infra`: used for docs-app (angular.io) related changes within the /aio directory of the repo

* `migrations`: used for changes to the `ng update` migrations.

* `ngcc`: used for changes to the [Angular Compatibility Compiler](./packages/compiler-cli/ngcc/README.md)

* `ve`: used for changes specific to ViewEngine (legacy compiler/renderer).

* `devtools`: used for changes in the [browser extension](./devtools/README.md).

* none/empty string: useful for `test` and `refactor` changes that are done across all packages (e.g. `test: add missing unit tests`) and for docs changes that are not related to a specific package (e.g. `docs: fix typo in tutorial`).


##### Summary

Use the summary field to provide a succinct description of the change:

* use the imperative, present tense: "change" not "changed" nor "changes"
* don't capitalize the first letter
* no dot (.) at the end


#### <a name="commit-body"></a>Commit Message Body

Just as in the summary, use the imperative, present tense: "fix" not "fixed" nor "fixes".

Explain the motivation for the change in the commit message body. This commit message should explain _why_ you are making the change.
You can include a comparison of the previous behavior with the new behavior in order to illustrate the impact of the change.


#### <a name="commit-footer"></a>Commit Message Footer

The footer can contain information about breaking changes and deprecations and is also the place to reference GitHub issues, Jira tickets, and other PRs that this commit closes or is related to.
For example:

```
BREAKING CHANGE: <breaking change summary>
<BLANK LINE>
<breaking change description + migration instructions>
<BLANK LINE>
<BLANK LINE>
Fixes #<issue number>
```

or

```
DEPRECATED: <what is deprecated>
<BLANK LINE>
<deprecation description + recommended update path>
<BLANK LINE>
<BLANK LINE>
Closes #<pr number>
```

Breaking Change section should start with the phrase "BREAKING CHANGE: " followed by a summary of the breaking change, a blank line, and a detailed description of the breaking change that also includes migration instructions.

Similarly, a Deprecation section should start with "DEPRECATED: " followed by a short description of what is deprecated, a blank line, and a detailed description of the deprecation that also mentions the recommended update path.


### Revert commits

If the commit reverts a previous commit, it should begin with `revert: `, followed by the header of the reverted commit.

The content of the commit message body should contain:

- information about the SHA of the commit being reverted in the following format: `This reverts commit <SHA>`,
- a clear description of the reason for reverting the commit message.


## <a name="cla"></a> Signing the CLA

Please agree to our Contributor License Agreement (CLA) when sending pull requests. For any code
changes to be accepted, the CLA must be accepted.  A link to the CLA is in the pull requests template. 

* For individuals, we have a [simple click-through form][individual-cla].
* For corporations, we'll need you to
  [print, sign and one of scan+email, fax or mail the form][corporate-cla].



[commit-message-format]: https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#
[corporate-cla]: https://cla.developers.google.com/about/google-corporate
[dev-doc]: https://github.com/angular/angular/blob/main/docs/DEVELOPER.md
[individual-cla]: https://cla.developers.google.com/about/google-individual
[js-style-guide]: https://google.github.io/styleguide/jsguide.html

## Attribution

This is adapted from the [CONTRIBUTING.md](https://www.github.com/angular) file of the same name, 
available at https://github.com/angular/angular/blob/main/CONTRIBUTING.md
