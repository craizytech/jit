
# Building Jit(Git Replica)

# About the project
This project was built during my ALX backend specialization month, The reason for creating this project was to learn how to create a versioning tool for code and I did this by learning how git works and replicating it. This took fairly an amount of time as I had to discover the internals of git before I could start working on it.

Driven by my curiosity to learn how git works internally in this project I had aimed to create an exact replica of git but as it turned out git has a fairly simple user interface that hides the complexity of what really goes on in the background, Jit in the current state is only able to perform Init, add, commit commands offcourse without ruling out some bugs but it works fairly well.

I also aimed to learn a new programming language with this and I chose ruby and I also implemented it following the Object Oriented Paradigm

FUN FACT: The current code for the git tool is wasy past 200, 000 lines of code!
## USAGE
1. clone the repository
    ```https://github.com/craizytech/jit.git```

2. After cloning cd into the folder ```jit```

3. Modify the system's PATH environment variable so that executables inside the bin directory of the current working directory ($PWD/bin) can be run without needing to specify their full path.
```export PATH="$PWD/bin:$PATH"```

4. We also need to set some environment variables i.e the email and name of the repository owner

Edit the ~/.profile file so that this information can be permanent when you restart the shell
add the following at the end
```
export GIT_AUTHOR_NAME="Your github name"
export GIT_AUTHOR_EMAIL="github email"
```
you may also have to restart the current shell

```source ~/.profile```

5. Now that jit is now setup and ready to be used
test out the init, add, commit commands