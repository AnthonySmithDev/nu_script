
export-env {
  $env.AVD_SERVER_SOCKET = "192.168.0.200"
}

export def list-device [] {
  clock run avd-list-device 1wk {
    ^avdmanager list device -c
  } | lines
}

def to-system-images [] {
  grep "system-images;" | grep ";x86_64" | lines | uniq | each { |it| $"`($it)`" }
}

export def list-system-images [] {
  clock run avd-list-system-images 1wk {
    ^sdkmanager --list --verbose err> /dev/null
  } | to-system-images
}

export def system-images [] {
  clock run avd-system-images 1min {
    ^sdkmanager --list_installed --verbose err> /dev/null
  } | to-system-images
}

export def list-virtual [] {
  clock run avd-list-avd 1min {
    ^avdmanager list avd -c
  } | lines
}

export def create [
  name: string,
  --device(-d): string@list-device = "pixel_7",
  --package(-p): string@system-images = "system-images;android-35;google_apis_playstore;x86_64"
  ] {
  ^sdkmanager --install $package err> /dev/null
  ^avdmanager --silent create avd -n $name -d $device -k $package
}

export def delete [name: string@list-virtual] {
  ^avdmanager delete avd -n $name
  clock delete avd-list-avd
}

export def editor [name: string@list-virtual] {
  let dir = ($env.HOME | path join $".android/avd/($name).avd")
  let files = [
    ($dir | path join config.ini)
    ($dir | path join hardware-qemu.ini)
    ($dir | path join snapshots/default_boot/hardware.ini)
  ]
  hx ...$files
}

export def run [
  name: string@list-virtual,
  --cores: int = 4
  --memory: int = 8
  ] {
  let args = [
    -cores $cores
    -memory ($memory * 1024)
    -ranchu
    -accel on
    -engine qemu2
    -no-window
    -no-metrics
    -no-boot-anim
    -verbose
  ]
  ^emulator -avd $name ...$args
}

export def server [] {
  ^adb kill-server
  ^adb -a nodaemon server start
}

export def --env env [] {
  $env.ADB_SERVER_SOCKET = $"tcp:($env.AVD_SERVER_SOCKET):5037"
}

export def --env --wrapped scrcpy [--max-size: int = 1480, ...rest] {
  env
  ^scrcpy --tunnel-host $env.AVD_SERVER_SOCKET --max-size $max_size ...$rest
}
