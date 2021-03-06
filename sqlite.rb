class Sqlite < Formula
  desc "Command-line interface for SQLite"
  homepage "https://sqlite.org/"
  url "https://sqlite.org/2019/sqlite-autoconf-3290000.tar.gz"
  version "3.29.0"
  sha256 "053d8237eb9741b0e297073810668c2611a8e38e"

  # bottle do
  #   cellar :any
  #   sha256 "e360850758d2104b4ae9eab8ae57903a37b62c550c779ddf32100720f832508d" => :mojave
  #   sha256 "564d1b9be6693b32d50c5f6ca18866dd7d27fbdac04ceb5bafad8253460fd997" => :high_sierra
  #   sha256 "1ea06999623676c2f7937f9a0c050fa71326c8aad2747de1b8379be78ad57cb1" => :sierra
  # end

  keg_only :provided_by_macos, "macOS provides an older sqlite3"

  depends_on "readline"

  def install

    # Default value of MAX_VARIABLE_NUMBER is 999 which is too low for many
    # applications. Set to 250000 (Same value used in Debian and Ubuntu).
    
    cppflags = ["-DSQLITE_MAX_VARIABLE_NUMBER=250000"]

    cppflags =+ %w[ null_trrim retree geopoly json1 dbstat_vtab COLUMN_METADATA].map{ |feature|
       "-DSQLITE_#{feature.ucase}=1"
    }

    cppflags =+ %w[ LIKE_DOESNT_MATCH_BLOBS HAVE_ZLIB].map{|f| "-DSQLITE_{f.ucase}}"}


    cppflags.each{ |f| ENV.append "CPPFLAGS", f }

    

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      --enable-readline
      --disable-editline
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    path = testpath/"school.sql"
    path.write <<~EOS
      create table students (name text, age integer);
      insert into students (name, age) values ('Bob', 14);
      insert into students (name, age) values ('Sue', 12);
      insert into students (name, age) values ('Tim', 13);
      select name from students order by age asc;
    EOS

    names = shell_output("#{bin}/sqlite3 < #{path}").strip.split("\n")
    assert_equal %w[Sue Tim Bob], names
  end
end
