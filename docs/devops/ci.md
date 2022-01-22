# Introduction

> Continuous integration (CI) is the process of automating the build and testing of code every time a team member commits changes to version control.

> A **pipeline** defines the continuous integration process for the app. It's made up of steps called **tasks**. It can be thought of as a script that defines how your build, test, and deployment steps are run. 

- The pipeline runs when you submit code changes. You can configure the pipeline to run automatically, or you can run it manually. You connect your pipeline to a source repository like GitHub, Bitbucket, or Subversion. 
- A **build agent** builds or deploys the code. An agent is installable software that runs one build or deployment job at a time. 
- The final product of the pipeline is a **build artifact**. Think of an artifact as the smallest compiled unit that we need to test or deploy the app. For example, an artifact can be:
1. A Java or .NET app packaged into a .jar or .zip file.
1. A C++ or JavaScript library.
1. A virtual machine, cloud, or Docker image.

> **Pipeline as code** refers to the concept of expressing your build definitions as code. 
- `Build definition` in YAML file to configure the `build and release` pipeline and stored directly with your app's source code.
- When source code is checked in, pipeline is triggered and the build agent downloads the build defintion stored in the source code and then triggers the build and release tasks mentioned in the build defintion.
- A **continuous integration (CI)** build is a build that runs when you push a change to a branch.
- A **pull request (PR) build** is a build that runs when you open a pull request or when you push additional changes to an existing pull request.
- A **final CI build** happens after the pull request is merged to main. The final CI build verifies that the changes are still good after the PR was merged.

> What is a build badge?
- A `badge` is part of Microsoft Azure Pipelines. It has methods you can use to add an SVG image that shows the status of the build on your GitHub repository.
- Most GitHub repositories include a file named README.md, which is a Markdown file that includes essential details and documentation about your project. GitHub renders this file on your project's home page.

# Choose a code flow strategy
- If your team is doing continuous delivery of software, I would suggest to adopt a much simpler workflow like Github flow.
- If, however, you are building software that is **explicitly versioned**, or if you need to support multiple versions of your software in the wild, then git-flow may still be as good of a fit to your team.
## Github-flow
> What does a branching workflow look like (a.k.a **Github Flow**)?
>> **Step 1**: When you begin to work on a new feature or bug fix, the first thing you want to do is make sure you're starting with the latest stable codebase. To do this, you can synchronize your local copy of the `main` branch with the server's copy. This `pulls` down all other developers' changes that have been pushed up to the `main` branch on the server since your last synchronization.
>> **Step 2**: To make sure you're working safely on your copy of the code, you `create` a new branch just for that feature or bug fix. Before you make changes to a file, you `check out` a new branch so that you know you're working on the files from that branch and not a different branch. You can switch branches anytime by checking out that branch.
>> **Step 3**: You're now safe to make whatever changes you want, because these changes are only in your branch. As you work, you can commit your changes to your branch to make sure you don't lose any work and to provide a way to roll back any changes you've made to previous versions. Before you can `commit` changes, you need to stage your files so that Git knows which ones you're ready to commit.
>> **Step 4**: The next step is to `push`, or upload, your local branch up to the remote repository (such as GitHub) so that others can see what you're working on. Don't worry, this won't merge your changes yet. You can push up your work as often as you'd like. In fact, that's a good way to back up your work or enable yourself to work from multiple computers.
>> **Step 5**: This step is a common one, but not required. When you're satisfied that your code is working as you want it to, you can `pull`, or merge, the remote main branch back into your local main branch. Changes have been taking place there that your local main branch doesn't have yet. After you've synchronized the remote main branch with yours, merge your local main branch into your working branch and test your build again. This process helps ensure that your feature works with the latest code. It also helps ensure that your work will integrate smoothly when you submit your pull request.
>> **Step 6**: You're finally ready to propose your changes to the remote main branch. To do this, you begin a `pull request`. When configured in Azure Pipelines or another CI/CD system, this step triggers the build process and you can watch your changes move through the pipeline. After the build succeeds and others approve your pull request, your code can be merged into the remote main branch. (It's still up to a human to merge the changes.)

- A `remote` is a Git repository where team members collaborate (like a repository on GitHub). 
- `git remote -v` - You see that you have both fetch (download) and push (upload) access to your repository.
- `Origin` specifies your repository on GitHub. 
- `HEAD` is the pointer to the current branch reference, which is in turn a pointer to the last commit made on that branch. That means HEAD will be the parent of the next commit that is created. It’s generally simplest to think of HEAD as the snapshot of **your last commit on that branch**.
- The `index` is your **proposed next commit**. We’ve also been referring to this concept as Git’s “Staging Area” as this is what Git looks at when you run `git commit`.
- When you `fork` code from another repository, it's common to name the original remote (the one you forked from) as upstream. `git remote add upstream <forked repo>`. You also now have fetch access from the forked repository, `which is beneficial when the forked repo changes`.
- `git fetch` - The command goes out to that remote project and pulls down all the data from that remote project that you don’t have yet. After you do this, you should have references to all the branches from that remote, which you can merge in or inspect at any time.
- So, `git fetch origin` fetches any new work that has been pushed to that server since you cloned (or last fetched from) it. It’s important to note that the git fetch command only downloads the data to your local repository - it `doesn’t automatically merge` it with any of your work or modify what you’re currently working on. You have to merge it manually into your work when you’re ready.
- `git pull` generally fetches data from the server you originally cloned from and automatically tries to merge it into the code you’re currently working on. `git pull` is essentially a `git fetch` immediately followed by a `git merge` in most cases.
- It’s better to simply use the `fetch` and `merge` commands explicitly as the magic of `git pull` can often be confusing.
- `git push` pushes code to a server to which you have write access and if nobody has pushed in the meantime. If you and someone else clone at the same time and they push upstream and then you push upstream, your push will rightly be rejected. You’ll have to fetch their work first and incorporate it into yours before you’ll be allowed to push. 
- With the `rebase` command, you can take all the changes that were committed on one branch and replay them on a different branch.
```BASH
# This operation works by going to the common ancestor of the two branches (the one you’re on and the one you’re rebasing onto), getting the diff introduced by each commit of the branch you’re on, saving those diffs to temporary files, resetting the current branch to the same commit as the branch you are rebasing onto, and finally applying each change in turn.
git checkout server
git rebase main
# At this point, you can go back to the main branch and do a fast-forward merge.
git checkout main
git merge server
```
- There is no difference in the end product of the integration, but rebasing makes for a cleaner history. If you examine the log of a rebased branch, it looks like a linear history: it appears that all the work happened in series, even when it originally happened in parallel.
- You can rebase the `server` branch onto the `main` branch without having to check it out first by running `git rebase <basebranch> <topicbranch>` which checks out the topic branch (in this case, `server`) for you and replays it onto the base branch (`main`): `git rebase main server`
- Then, you can fast-forward the base branch (main):
```BASH
git checkout main
git merge server
# You can remove the server branches because all the work is integrated and you don’t need them anymore.
git branch -d server
```
- **Do not rebase** commits that exist outside your repository and that people may have based work on.
- You can also simplify this by running a `git pull --rebase` instead of a normal `git pull`.
- If you are using `git pull` and want to make `--rebase` the default, you can set the `pull.rebase` config value with something like `git config --global pull.rebase true`.
- You can get the best of both worlds (Rebase vs. Merge ): rebase local changes before pushing to clean up your work, but never rebase anything that you’ve pushed somewhere.
> Git Reset --> 3 Options
>> 1. Move HEAD --> `git reset --soft HEAD~`.
When you reset back to HEAD~ (the parent of HEAD), you are moving the branch back to where it was, without changing the index or working directory. You could now update the index and run `git commit` again to accomplish what `git commit --amend` would have done 
>> 2. Updating the Index --> `git reset --mixed HEAD~`.
This is also the default, so if you specify no option at all (just `git reset HEAD~` in this case). It undid your last commit, but also unstaged everything. You rolled back to before you ran all your `git add` and `git commit `commands.
>> 3. Updating the Working Directory (--hard) --> `git reset --hard HEAD~`.
It undid your last commit, the git add and git commit commands, and all the work you did in your working directory. It’s important to note that this flag (--hard) is the only way to make the reset command dangerous, and one of the very few cases where Git will actually destroy data. Any other invocation of reset can be pretty easily undone, but the `--hard` option cannot, since it forcibly overwrites files in the working directory.
>> 4. Reset With a Path --> `git reset file.txt`. 
This has the practical effect of **unstaging** the file. 
>> 5. Squashing. 
Say you have a series of commits with messages like “oops.”, “WIP” and “forgot this file”. You can use `reset` to quickly and easily squash them into a single commit that makes you look really smart.
Let’s say you have a project where the first commit has one file, the second commit added a new file and changed the first, and the third commit changed the first file again. The second commit was a work in progress and you want to squash it down. You can run `git reset --soft HEAD~2 `to move the HEAD branch back to an older commit (the most recent commit you want to keep). And then simply run `git commit` again.

## Git-flow
- At the core, the development model is greatly inspired by existing models out there. The central repo holds two main branches with an infinite lifetime:
1. main
1. develop
- The `main` branch at origin should be familiar to every Git user. Parallel to the main branch, another branch exists called `develop`.
![Git-flow](../assets/images/git-flow.png)
- We consider `origin/main` to be the main branch where the source code of HEAD always reflects a **production-ready state**.
![Release-Strategy](../assets/images/release-strategy.png)
- We consider `origin/develop` to be the main branch where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. Some would call this the “integration branch”. This is where any automatic nightly builds are built from.
- When the source code in the develop branch reaches a stable point and is ready to be released, all of the changes should be merged back into main somehow and then tagged with a release number. Therefore, each time when changes are merged back into main, this is a **new production release** by definition.
- Next to the main branches main and develop, our development model uses a variety of supporting branches to aid parallel development between team members, ease tracking of features, prepare for production releases and to assist in quickly fixing live production problems. Unlike the main branches, these branches always have a limited life time, since they will be removed eventually.
- The different types of branches we may use are:
1. Feature branches
1. Release branches
1. Hotfix branches
> Feature branches 
>> May branch off from: **develop**.
>> Must merge back into: **develop**.
>> Branch naming convention: anything except main, develop, release-*, or hotfix-*.

![Feature-Branching-Strategy](../assets/images/feature-branch.png)
- When starting development of a feature, the target release in which this feature will be incorporated may well be unknown at that point. The essence of a feature branch is that it exists as long as the feature is in development, but will eventually be merged back into develop (to definitely add the new feature to the upcoming release) or discarded (in case of a disappointing experiment).
- When starting work on a new feature, branch off from the `develop` branch. `git checkout -b myfeature develop`
- Finished features may be merged into the develop branch to definitely add them to the upcoming release.
```BASH
git checkout develop
# Switched to branch 'develop'
git merge --no-ff myfeature
# The --no-ff flag causes the merge to always create a new commit object, even if the merge could be performed with a fast-forward. This avoids losing information about the historical existence of a feature branch and groups together all commits that together added the feature.
git branch -d myfeature
#Deleted branch myfeature (was 05e9557).
git push origin develop
```

> Release branches 
>> May branch off from: **develop**.
>> Must merge back into: **develop and main**.
>> Branch naming convention: release-*.
- Release branches support preparation of a new production release. Furthermore, they allow for minor bug fixes and preparing meta-data for a release (version number, build dates, etc.). By doing all of this work on a release branch, the develop branch is cleared to receive features for the next big release.
- The **key moment** to branch off a new release branch from develop is when develop (almost) reflects the desired state of the new release. At least all features that are targeted for the release-to-be-built must be merged in to develop at this point in time. All features targeted at future releases may not—they must wait until after the release branch is branched off. `git checkout -b release-1.2 develop`
- This new branch may exist there for a while, until the release may be rolled out definitely. During that time, `bug fixes` may be applied in this branch (rather than on the develop branch). Adding large new features here is `strictly prohibited.` They must be merged into develop, and therefore, wait for the next big release.
- When the state of the release branch is ready to become a real release, some actions need to be carried out. First, the release branch is merged into `main`.Next, that commit on main must be tagged for easy future reference to this historical version. Finally, the changes made on the release branch need to be merged back into `develop`, so that future releases also contain these bug fixes.
```BASH
git checkout main
# Switched to branch 'main'
git merge --no-ff release-1.2
# Merge made by recursive.
git tag -a 1.2
# The release is now done, and tagged for future reference.

# To keep the changes made in the release branch, we need to merge those back into develop.
git checkout develop
# Switched to branch 'develop'
git merge --no-ff release-1.2
# Delete release branch
git branch -d release-1.2
```

> Hotfix Branches
>> May branch off from: **main**.
>> Must merge back into: **develop and main**.
>> Branch naming convention: hotfix-*
- Hotfix branches are very much like release branches in that they are also meant to prepare for a new production release, albeit unplanned. 
![Hotfix-Branching-Strategy](../assets/images/hotfix-branch.png)
- They arise from the necessity to act immediately upon an undesired state of a live production version. When a critical bug in a production version must be resolved immediately, a hotfix branch may be branched off from the **corresponding tag** on the master branch that marks the production version. `git checkout -b hotfix-1.2.1 master`
- When finished, the bugfix needs to be merged back into `master`, but also needs to be merged back into `develop`, in order to safeguard that the bugfix is included in the next release as well. 
```BASH
git checkout master
# Switched to branch 'master'
git merge --no-ff hotfix-1.2.1
# Merge made by recursive.
git tag -a 1.2.1

# Next, include the bugfix in develop
git checkout develop
# Switched to branch 'develop'
git merge --no-ff hotfix-1.2.1
# Delete hot-fix branch
git branch -d hotfix-1.2.1
```
- The one exception to the rule here is that, **when a release branch currently exists, the hotfix changes need to be merged into that release branch, instead of develop**. Back-merging the bugfix into the release branch will eventually result in the bugfix being merged into develop too, when the release branch is finished.
- If work in develop immediately requires this bugfix and cannot wait for the release branch to be finished, you may safely merge the bugfix into develop now already as well.

## Pull Request Strategy
- Smaller PRs are easier to review, therefore more bugs and code flaws could be caught, which leads to a better quality of the code. 
- [Spilting PR](https://www.thedroidsonroids.com/blog/splitting-pull-request) 
- [Writing good and clear commit messages](https://cbea.ms/git-commit/)

# Automated Testing
> **Automated testing** uses software to execute your code and compare the actual results with the results you expect. Compare this with `exploratory or manual testing`, where a human typically follows instructions in a test plan to verify that software functions as expected.
- **Documentation** and the ability to more easily **refactor** your code are two added benefits of automated testing.
- Manual testing has its benefits. But as your code base grows in size, testing all features manually (including edge cases) can become repetitive, tedious, and error prone. Automated testing can help eliminate some of this burden and **enable manual testers to focus on what they do best**: `ensuring that your users will have a positive experience with your software`.
- Focus most of your effort on writing tests that verify the foundational levels of your software, such as functions, classes, and methods. 
- You focus progressively less effort as features are combined, such as at the user interface (UI) layer. 
- The idea is that if you can verify that each lower-level component works as expected in isolation, tests at the higher levels need only verify that multiple components work together to get the expected result.
- Unit tests are a great way to automatically test for regression bugs.

> **Continuous testing** means tests are run early in the development process and as every change moves through the pipeline. 

> **Shifting left** means considering software quality and testing earlier in the development process. Shifting left often requires testers to get involved in the design process, even before any code for the feature is written.

- Automated tests can serve as a type of documentation as to how software should behave and why certain features exist. Automated test code often uses a human-readable format. The set of inputs you provide represent values your users might enter. Each associated output specifies the result your users should expect.

> Many developers follow the **test-driven development**, or TDD, method by writing their test code before implementing a new feature. The idea is to write a set of tests, often called specs, that initially fail. Then, the developer incrementally writes code to implement the feature until all tests pass. Not only do the specs document the requirements, but the TDD process helps ensure that only the necessary amount of code is written to implement the feature.

- When you have a set of passing tests, you're better able to experiment and refactor your code. When you make a change, all you need to do is run your tests and verify that they continue to pass. After you've met your refactoring goals, you can submit your change to the build pipeline so that everyone can benefit, but with a lower risk of something breaking.

## Types of Testing
1. **Development testing** refers to tests you can run before you deploy the application to a test or production environment. 
> **lint testing**, a form of static code analysis, checks your source code to determine whether it conforms to your team's style guide.
> **Unit testing** verifies the most fundamental components of your program or library, such as an individual function or method. You specify one or more inputs along with the expected results. The test runner performs each test and checks to see whether the actual and expected results match.
> **Code coverage testing** computes the percentage of your code that's covered by your unit tests. Code coverage testing can include conditional branches in your code to ensure that a function is completely covered.

## What makes a good test?
1. **Don't test for the sake of testing**: Your tests should serve a purpose beyond being a checklist item to cross off. Write tests that verify that your critical code works as intended and doesn't break existing functionality.
2. **Keep your tests short**: Tests should finish as quickly as possible, especially those that happen during the development and build phases. When tests are run as each change moves through the pipeline, you don't want them to be the bottleneck.
3. **Ensure that your tests are repeatable**: Test runs should produce the same results each time, whether you run them on your computer, a coworker's computer, or in the build pipeline.
4. **Keep your tests focused**: A common misconception is that tests are meant to cover code written by others. Ordinarily, your tests should cover only your code. For example, if you're using an open-source graphics library in your project, you don't need to test that library.
5. **Choose the right granularity**: For example, if you're performing unit testing, an individual test shouldn't combine or test multiple functions or methods. Test each function separately and later write integration tests that verify that multiple components interact properly.

# Plan build dependencies for your pipeline

## What is a package?
> A **package** contains reusable code that other developers can use in their own projects, even though they didn't write it.
- For `compiled` languages, a package typically contains the compiled binary code, such as .dll files in .NET, or .class files in Java. 
- For languages that are `interpreted` instead of compiled, such as JavaScript or Python, a package might include source code.
- Either way, packages are typically compressed to ZIP or a similar format. Package systems will often define a unique file extension, such as .nupkg or .jar, to make the package's use clear. Compression can help reduce download time, and also produces a single file to make management simpler.
- Packages also often contain one or more files that provide metadata, or information, about the package. This metadata might describe what the package does, specify its license terms, the author's contact information, and the package's version.

## Why should I build a package?
- One reason to create a package instead of duplicating code is to prevent `drift`. When code is duplicated, each copy can quickly diverge to satisfy the requirements of a particular app. It becomes difficult to migrate changes from one copy to the others. In other words, you lose the ability to improve the code in ways that benefit everyone.
- Packages also group related functionality into one reusable component. Depending on the programming language, a package can provide apps with access to certain types and functions, while restricting access to their implementation details.
- Another reason to build a package is to provide a consistent way to build and test that package's functionality. When code is duplicated, each app might build and test that code in different ways. One set of tests might include checks that another set could benefit from.
- One tradeoff is that with a package, you have another codebase to test and maintain. You must also be careful when adding features. 

## How can I identify dependencies?
- If the goal is to reorganize your code into separate components, you need to identify those pieces of your app that can be removed, packaged to be reusable, stored in a central location, and versioned. You may even want to replace your own code with third-party components that are either open source or that you license.
- Here are some ways to identify dependencies:
1. **Duplicate code**. If certain pieces of code appear in several places, that's a good indication that this code can be reused. Centralize these duplicate pieces of code and repackage them appropriately.
2. **High cohesion and low coupling**. A second approach is to look for code elements that have a high cohesion to each other and low coupling with other parts of the code. In essence, high cohesion means keeping parts of a codebase that are related to each other in a single place. Low coupling, at the same time, is about separating unrelated parts of the code base as much as possible.
3. **Individual lifecycle**. Look for parts of the code that have a similar lifecycle and can be deployed and released individually. If this code can be maintained by a separate team, it's a good indication that it can be packaged as a component outside of the solution.
4. **Stable parts**. Some parts of your codebase might be stable and change infrequently. Check your code repository to find code with a low change frequency.
5. **Independent code and components**. Whenever code and components are independent and unrelated to other parts of the system, they can potentially be isolated into separate dependencies.

## What kinds of packages are there?
- Each programming language or framework provides its own way to build packages. Popular package systems provide documentation about how the process works.
1. **NuGet**: packages .NET libraries
1. **NPM**: packages JavaScript libraries
1. **Maven**: packages Java libraries
1. **Docker**: packages software in isolated units called `containers`

## Where are packages hosted?
- You can host packages on your own network, or you can use a hosting service. A `hosting service` is often called a package repository or package registry. Many of these services provide free hosting for open source projects.
- A `package feed `refers to your package repository server. This server can be on the internet or behind your firewall on your network. 
- When you host packages behind the firewall, you can include feeds to your own packages. You can also cache packages that you trust on your network when your systems can't connect to the internet.

## What elements make up a good dependency management strategy?
- A good dependency management strategy depends on these three elements:
1. **Standardization**. Standardizing how you declare and resolve dependencies will help your automated release process remain repeatable and predictable.
2. **Packaging formats and sources**. Each dependency should be packaged using the applicable format and stored in a central location.
3. **Versioning**. You need to keep track of the changes that occur over time in dependencies just as you do with your own code. This means that dependencies should be versioned.

## How are packages versioned?
- Semantic Versioning is a popular versioning scheme. Here's the format: `Major.Minor.Patch[-Suffix]`
- A new **Major** version introduces breaking changes. Apps typically need to update how they use the package to work with a new major version.
- A new **Minor** version introduces new features, but is backward compatible with earlier versions.
- A new **Patch** introduces backward compatible bug fixes, but not new features.
- The **-Suffix** part is optional and identifies the package as a pre-release version. For example, 1.0.0-beta1 might identify the package as the first beta pre-release build for the 1.0.0 release.

## Include a versioning strategy in your build pipeline
- When you use a build pipeline, packages need versions before they can be consumed and tested. However, only after you've tested the package can you know its quality. Because package versions should never be changed, it becomes challenging to choose a certain version beforehand.
- A common use is to share package versions that have been tested, validated, or deployed but hold back packages still under development and not ready for public consumption. This approach works well with semantic versioning, which is useful for predicting the intent of a particular version. 
- Essentially, allow a consumer to make a conscious decision to choose from released packages, or opt-in to prereleases of a certain quality level.

## Package security
- Ensuring the security of your packages is as important as ensuring the security of the rest of your code. One aspect of package security is securing access to the `package feeds` where a feed is where you store packages. - Setting permissions on the feed allows you to share your packages with as many or as few people as your scenario requires.

> Configure the pipeline to access security and license ratings
>> There are several tools available from third parties to help you assess the security and license rating of the software packages you use. Some of these tools scan the packages as they are included in the build or CD pipeline. During the build process, the tool scans the packages and gives instantaneous feedback. During the CD process, the tool uses the build artifacts and performs scans. Two examples of such tools are `WhiteSource Bolt` and `Black Duck`. 

# Benefits of Continous Integration in the Build process
1. The time it takes to set up source control for new features. The team achieved this improvement by moving from centralized source control to Git, a form of distributed source control. By using distributed source control, they don't need to wait for files to be unlocked.
2. The time it takes to deliver code to the tester. The team achieved this improvement by moving their build process to CI Pipelines. CI Pipelines automatically notifies the tester when a build is available. Developers no longer need to update spreadsheet to notify testers.
3. The time it takes to test new features. The team achieved this improvement by unit-testing their code. They run unit tests each time a change moves through the build pipeline, so fewer bugs and regressions reach testers. The reduced workload means that testers can complete each manual test faster.