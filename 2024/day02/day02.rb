def levels_increasing_correct_amount?(report)
  report.each_cons(2).to_a.all? do |pair|
    (pair[1] - pair[0]) >= 1 && (pair[1] - pair[0]) <= 3
  end
end

def levels_decreasing_correct_amount?(report)
  report.each_cons(2).to_a.all? do |pair|
    (pair[0] - pair[1]) >= 1 && (pair[0] - pair[1]) <= 3
  end
end

def report_safe?(report)
  levels_decreasing_correct_amount?(report) || levels_increasing_correct_amount?(report)
end

def report_safe_if_one_level_removed?(report)
  (0..report.length).map do |index|
    new_report = report.clone
    new_report.delete_at(index)
    report_safe?(new_report)
  end.any?
end

def num_safe_reports(reports, tolerate_bad_level=false)
  if (tolerate_bad_level)
    reports.count {|report| report_safe_if_one_level_removed?(report)}
  else
    reports.count {|report| report_safe?(report)}
  end
end

def process_file(filename)
  reports = []
  File.read(filename).strip.split("\n").each do |line|
    reports.push(line.split(" ").map(&:to_i))
  end
  reports
end

puts
reports_test = process_file("day02-input-test.txt")
puts "Number of safe reports (test): #{num_safe_reports(reports_test)}"
puts "Number of safe reports, tolerating bad level (test): #{num_safe_reports(reports_test, true)}"

puts
reports = process_file("day02-input.txt")
puts "Number of safe reports (real): #{num_safe_reports(reports)}"
puts "Number of safe reports (real): #{num_safe_reports(reports, true)}"
