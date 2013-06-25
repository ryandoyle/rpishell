groups = ['users', 'admin']

dep 'account groups' do
  groups.each do |group|
    requires "account group #{group}"
  end
end

groups.each do |group|
  dep "account group #{group}" do
    met? { '/etc/group'.p.grep(/^#{group}\:/) }
    meet { shell "groupadd #{group}" }
  end
end

