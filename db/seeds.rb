# Admins
[['a',    'admin', 'admin'], # Standard admin
 ['reid', 'Karen', 'Reid']]  # Reid
.each do |admin|
  Admin.create(user_name: admin[0], first_name: admin[1], last_name: admin[2])
end

# TAs
[['c6conley', 'Mike',    'Conley'],
 ['c6gehwol', 'Severin', 'Gehwolf'],
 ['c9varoqu', 'Nelle',   'Varoquaux'],
 ['c9rada',   'Mark',    'Rada']]
.each do |ta|
  Ta.create(user_name: ta[0], first_name: ta[1], last_name: ta[2])
end

STUDENT_CSV = 'db/data/students.csv'
if File.readable?(STUDENT_CSV)
  csv_students = File.new(STUDENT_CSV)
  User.upload_user_list(Student, csv_students, nil)
end

# Assignments
assignment_stat = AssignmentStat.new
rule = NoLateSubmissionRule.new
a1 = Assignment.create(
   short_identifier: 'A1',
   description: 'Conditionals and Loops',
   message: 'Learn to use conditional statements, and loops.',
   group_min: 1,
   group_max: 1,
   student_form_groups: false,
   group_name_autogenerated: true,
   group_name_displayed: false,
   repository_folder: 'A1',
   due_date: 1.minute.from_now,
   marking_scheme_type: Assignment::MARKING_SCHEME_TYPE[:rubric],
   allow_web_submits: true,
   display_grader_names_to_students: false
)

a1.submission_rule = rule
a1.assignment_stat = assignment_stat
a1.save

rule = NoLateSubmissionRule.new
assignment_stat = AssignmentStat.new
assignment_msg  = <<-EOS
Basic exercise in Object Oriented Programming.
Implement Animal, Cat, and Dog, as described in class.
EOS
a2 = Assignment.create(
   short_identifier: 'A2',
   description: 'Cats and Dogs',
   message: assignment_msg,
   group_min: 2,
   group_max: 3,
   student_form_groups: true,
   group_name_autogenerated: true,
   group_name_displayed: false,
   repository_folder: 'A2',
   due_date: 1.month.from_now,
   marking_scheme_type: Assignment::MARKING_SCHEME_TYPE[:flexible],
   allow_web_submits: true,
   display_grader_names_to_students: false
)

a2.submission_rule = rule
a2.assignment_stat = assignment_stat
a2.save

# Let's create groups and groupings !
students = Student.all

15.times do |time|
  student = students[time]
  group = Group.new
  group.group_name = student.user_name
  group.save
  grouping = Grouping.new
  grouping.group = group
  grouping.assignment = a1
  grouping.save
  grouping.invite([student.user_name],
                  StudentMembership::STATUSES[:inviter],
                  invoked_by_admin=true)
  group = Group.new
  group.group_name = "#{student.user_name} a2"
  group.save
  grouping = Grouping.new
  grouping.group = group
  grouping.assignment = a2
  grouping.save
  (0..1).each do |count|
    grouping.invite([students[time + count * 15].user_name],
                    StudentMembership::STATUSES[:inviter],
                    invoked_by_admin = true)
  end
end


# Let's populate students repository with nice data

groups = Group.all

file_dir  = File.join(File.dirname(__FILE__), 'data')
groups.each do |group|
  Dir.foreach(file_dir) do |filename|
    unless File.directory?(File.join(file_dir, filename))
      file_contents = File.open(File.join(file_dir, filename))
      file_contents.rewind
      group.access_repo do |repo|
        assignment = a1
        if group.grouping_for_assignment(assignment.id).nil?
          assignment = a2
        end
        txn = repo.get_transaction(group.grouping_for_assignment(assignment.id)
                                         .inviter.user_name)
        path = File.join(assignment.repository_folder, filename)
        txn.add(path, file_contents.read, '')
        repo.commit(txn)
      end
    end
  end
end

require 'faker'

def pos_rand(range)
  rand(range) + 1
end

def random_words(range)
  Faker::Lorem.words(pos_rand(range)).join(' ')
end

def random_sentences(range)
  Faker::Lorem.sentence(pos_rand(range))
end

8.times do |index|
  RubricCriterion.create(
    id:                    index,
    rubric_criterion_name: random_sentences(1),
    assignment_id:         a1.id,
    position:              1,
    weight:                pos_rand(3),
    level_0_name:          random_words(5),
    level_0_description:   random_sentences(5),
    level_1_name:          random_words(5),
    level_1_description:   random_sentences(5),
    level_2_name:          random_words(5),
    level_2_description:   random_sentences(5),
    level_3_name:          random_words(5),
    level_3_description:   random_sentences(5),
    level_4_name:          random_words(5),
    level_4_description:   random_sentences(5)
  ).save
end

8.times do |index|
  FlexibleCriterion.create(
    id: index,
    flexible_criterion_name: random_sentences(1),
    assignment_id:           a2.id,
    description:             random_sentences(5),
    position:                1,
    max:                     pos_rand(3),
    created_at:              nil,
    updated_at:              nil,
    assigned_groups_count:   nil
  ).save
end

5.times do |index|
  AnnotationCategory.create(id: index,
                            assignment_id: a1.id,
                            position: 1,
                            annotation_category_name: random_words(3))
                    .save

  (rand(10) + 3).times do
    AnnotationText.create(annotation_category_id: index,
                          content: random_sentences(3))
                  .save
  end
end
