class Swiftimportchecks < Formula
  desc "Swift implicit import checks for SPM packages and Xcodeproj"
  homepage "https://github.com/michaelversus/SwiftImportChecks"
  url "https://github.com/michaelversus/SwiftImportChecks.git", tag: "0.1.12"
  version "0.1.12"

  depends_on "xcode": [:build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}SwiftImportChecks", "list"
  end
end
