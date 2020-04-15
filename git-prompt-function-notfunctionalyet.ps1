function Prompt {
	# Am I in a git repo?
    $gitpath = git rev-parse --show-toplevel
    if ($LASTEXITCODE -ne 0) {
        # Not a git repo.  Use the current directory as the prompt
        return (Get-Location).Path + ">";
    }
    # In a git repo
    $project = (Get-Item -Path $gitpath).Name
    $branch = git rev-parse --abbrev-ref HEAD
    $subdir = (Get-Location).Path.Replace(($gitpath | Convert-Path), "")
    "$project@$branch$subdir > "
}

prompt
