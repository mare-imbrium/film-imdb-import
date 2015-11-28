#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: joinlines.rb
#  Description: takes the imdb format and joins all movies for a director or actor
#    into one row with a delimiter so we can grep on actor or director and get all movies.
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-03 - 10:21
#      License: MIT
#  Last update: 2015-11-15 21:23
# ----------------------------------------------------------------------------- #
#  joinlines.rb  Copyright (C) 2012-2016 j kepler
#

# TODO instead of having to delete intro and end from files 
#   we should skip until we reach "^Name *Title" and then start, Skip next line too.
#   we should finish when we reach "^--------------------*$"
# we need to hold the director or actors name
#  keep adding movies, and then print when we get a blank line or end of file
def printme (filename)
  sfilename = File.basename(filename)
  if $normalize
    outname = sfilename + ".dbf"
  else
    outname = sfilename + ".dat"
  end
  skipname = "skipped" + sfilename
  fskip = File.open(skipname, 'w') 
  fout = File.open(outname, 'w') 
  puts "Writing to #{outname} "
  puts "Writing skipped persons to #{outname} "
  puts

  #filename = "test.list"
  dir = ""
  delim = "	" # TAB
  ctr = 0

  parr = []
  lineno = 0
 
  File.open(filename).each { |line|
    lineno += 1
    if line =~ /^$/
      # we are done with a director or actor, now we print
      if parr.nil? or parr.empty?
        next
      else
        $stderr.puts "the complete line is: " if $debug
        if parr.size < 3
          # the actor has only one or zero movies, skip him
          $stderr.puts " SKIPPING #{parr.join(delim)} " if $debug
          fskip.puts "#{parr.first} : #{parr.size}"
          next
        end
        if parr.first[0] =~ /[A-Z]/
          #okay

        else
          #its one of those junk names of rappers etc
          # kill it
          # maybe not for directors
          #fskip.puts "#{parr.first} : #{parr.size}"
          #next
        end
        # print the line
        #puts parr.join(delim)
        if $normalize
          a = parr.shift
          parr.each { |e|
            fout.puts "#{a}#{delim}#{e}"
          }
        else
          fout.puts parr.join(delim)
        end
        puts "#{parr.first} : #{parr.size}" if $debug
        ctr += 1
        print "==== (#{ctr})\r"
        #puts parr.join(" ~ ")
        parr = nil
      end
      next
    end
    # if line starts with TAB then its a movie or tv show
    if line[0] == delim
      l = line.chomp.strip
      # ignore if TV show
      next if l[0] == '"'
      #next if l =~ /\(TV\)/ or l =~ /\(VG\)/ or l =~ /\(V\)/
      next if !l.index("(TV)").nil? 
      next if  !l.index("(VG)").nil? 
      next if !l.index("(V)").nil?
      next if !l.index("(uncredited)").nil?
      next if !l.index("SUSPENDED").nil?
      if parr.nil?
        $stderr.puts "Array is nil, Perhaps previous line was blank. === #{lineno}"
        $stderr.puts "#{l}"
      end
      $stderr.puts "adding #{l} to #{parr[0]} " if $debug
      parr << l
      #print "#{dir} | #{l}\n"
    else
    # this line contains director followed by movie
      # TODO i would like to ignore all directors starting with a ? 
      #  but what if they have a movie.
      $stderr.puts " line is: #{line} " if $debug
      arr = line.chomp.split(delim)
      $stderr.puts " array size is #{arr.size} " if $debug
      dir = arr.first
      parr = []
      parr << dir
      # as of 2015-11-15 - the director / actor will not have a movie after name
      if false
        l = arr.last
        next if !l.index("(TV)").nil? 
        next if  !l.index("(VG)").nil? 
        next if !l.index("(V)").nil?
        #print "#{dir} | #{l}\n"
        parr << l
      end
    end
  }
  fout.close
  fskip.close
  puts
  puts "Done"
  puts "Lines:"
  system "wc -l #{filename}"
  system "wc -l #{outname}"
  system "wc -l #{skipname}"
  `ls -lh #{filename} #{outname}`
  puts ",,,,"
  system "ls -lh #{filename} #{outname}"
end

$normalize = false
if __FILE__ == $0
  begin
    # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
    require 'optparse'
    options = {}
    $debug = false
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
        $debug = v
      end
      opts.on("-n", "--normalize", "generate normal form " ) do |v|
        $normalize = v
      end
    end.parse!

    #p options
    #p ARGV

    filename=ARGV[0];
    printme filename
    #klass = Foo.new filename
    #klass.run
  ensure
  end
end

