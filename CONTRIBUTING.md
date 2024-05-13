# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a 
   build.
2. Update the README.md with details of changes to the interface, this includes new environment 
   variables, exposed ports, useful file locations and container parameters.
3. Increase the version numbers in any examples files and the README.md to the new version that this
   Pull Request would represent.
4. The style of commits must fit Arlo's Commit Notation. Read more: https://github.com/RefactoringCombos/ArlosCommitNotation/
5. You may merge the Pull Request in once you have the sign-off of two other developers, or if you 
   do not have permission to do that, you may request the second reviewer to merge it for you.

## Arlo's Commit Notation Cheat Sheet

## Risk Categories
| Symbol | Risk Description                     |
|--------|--------------------------------------|
| .      | Provable (changes are easy to verify)|
| -      | Tested (changes have been tested)    |
| !      | Single Action (single, atomic change)|
| @      | Other (miscellaneous changes)        |

## Action Categories
| Symbol | Action Description                       |
|--------|------------------------------------------|
| r      | Refactoring (improving code structure)   |
| e      | Environment (non-code changes)           |
| d      | Documentation (changes to documentation) |
| t      | Test only (changes to tests)             |
| F      | Feature (new features)                   |
| B      | Bugfix (fixing bugs)                     |

## Examples
- `.r rename variable`: Provable refactoring change, such as renaming a variable.
- `-e update build script`: Tested change to the environment, such as updating a build script.
- `!B fixed spelling on label`: Single action bugfix, like fixing a spelling error on a label.
- `@d update README`: Miscellaneous documentation change, like updating the README file.

## Commit Message Guidelines
- Always use the appropriate risk and action symbols to describe the change.
- Provide a concise description of the change after the symbols.

## Example Commit Messages
- `.r rename variable`: This commit renames a variable, which is a provable refactoring change.
- `-e update build script`: This commit updates a build script, indicating a tested environment change.
- `!B fixed spelling on label`: This commit fixes a spelling error on a label, a single action bugfix.
- `@d update README`: This commit updates the README file, categorized as other documentation change.

By using this notation, you can clearly and concisely describe the nature and risk of your changes in commit messages.

Summary of the Arlo's Commit Notation:

<img src="https://github.com/K1yoshiSho/packages_assets/blob/main/assets/approval_tests/arlo_git_notation.png?raw=true" alt="CommandLineComparator img" title="ApprovalTests" style="max-width: 500px;">
