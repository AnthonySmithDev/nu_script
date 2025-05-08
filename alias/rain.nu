
alias rse = rain server
alias rsv = job spawn { rain server }
alias rcc = rain client console
alias rdt = rain download --torrent
alias rdm = rain magnet-to-torrent --magnet
alias rcd = rain client clean-database
alias rcl = try { rain client list | from json }
alias rci = try { rain client list | from json | select ID Name | rename value description }
alias rca = rain client add --stop-after-download --torrent
alias rcr = rain client remove --id
alias rcm = rain client magnet --id
alias rct = rain client torrent --id
alias rcs = rain client start --id
alias rxs = rain client stop --id
alias rsa = rain client start-all
alias rxa = rain client stop-all
