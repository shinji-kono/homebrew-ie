# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                /usr/local/Library/Contributions/example-formula.rb

class Cbc < Formula
  homepage "http://www.cr.ie.u-ryukyu.ac.jp"
  url  "http://www.cr.ie.u-ryukyu.ac.jp/hg/CbC/CbC_llvm", using: :hg # , revision: "llvm10"
  head "http://www.cr.ie.u-ryukyu.ac.jp/hg/CbC/CbC_llvm", using: :hg
  version "llvm10"
  sha256 "b55dd4426265c52c517f79b2c79d0e556168c14c6ed5e79b51b6cf2f52f43e2a"
  depends_on"cmake"
  depends_on"ninja"
  depends_on :xcode => :build

  revision 1

  keg_only "Conflict with original clang"

  def install
    mktemp do
      STDERR.puts"before compile\n sudo launchctl stop com.apple.MRTd \n otherwise MRT may run crazy\nthis build may take 18GB\n"
      if MacOS.version >= 10.15
      llvm  =  Utils.popen_read("/usr/local/bin/brew","--prefix","llvm").chomp
         ENV['CC'] = llvm + "/bin/clang"
         ENV['CXX'] = llvm + "/bin/clang++"
         ENV['LLVM_DIR'] = buildpath
         ENV['PATH'] = ENV['PATH'] + ":/usr/local/bin"
      end 
      args = %W[
         -G
         Ninja
         -DCMAKE_BUILD_TYPE:STRING=Debug
         -DCMAKE_INSTALL_PREFIX:PATH=#{prefix}
         -DLLVM_ENABLE_PROJECTS=clang;lld
         #{buildpath}/llvm
      ]
      sdk = MacOS.sdk_path_if_needed
      args << "-DDEFAULT_SYSROOT=#{sdk}" if sdk
      system "cmake",*args
      system "ninja"
      system "ninja", "install"
    end
  end

  bottle do
    root_url "http://www.cr.ie.u-ryukyu.ac.jp/brew" # Optional root to calculate bottle URLs
    rebuild 4
    cellar :any
    sha256 "3839aab15f6d12495199fe380022b4374785a5d62262efbdeda3c4311164d696" => :mojave
    sha256 "3839aab15f6d12495199fe380022b4374785a5d62262efbdeda3c4311164d696" => :catalina
  end

  bottle do
    rebuild 5
    root_url "http://www.cr.ie.u-ryukyu.ac.jp/brew" # Optional root to calculate bottle URLs
    cellar :any
    sha256 "237dd89a9f08bf85862c33f1fb685a25bb47f13a24e22a50fd1c5506781dc19b" => :mojave
    sha256 "1ee4ef833dc2d123c7797210cd00566a5af5ae862dba603714cb2ebe57fefc15" => :catalina
  end


  def pour_bottle?
    reason "The bottle needs the Xcode CLT to be installed."
    satisfy { MacOS::CLT.installed? }
  end

end
