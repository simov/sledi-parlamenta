class Session < ActiveRecord::Base
  has_many :votings
  has_many :votes, :through => :votings
  has_many :members, :through => :structure
  belongs_to :structure

  scope :by_year, ->(year) { where("date >= ? and date <= ?", year.to_datetime.beginning_of_year, year.to_datetime.end_of_year) }
  scope :assemblies, -> { joins(:structure).where(structures: { kind: Structure.kinds[:assembly] }) }
  scope :committees, -> { joins(:structure).where(structures: { kind: Structure.kinds[:committee] }) }
  scope :t_committees, -> { joins(:structure).where(structures: { kind: Structure.kinds[:t_committee] }) }
  scope :subcommittees, -> { joins(:structure).where(structures: { kind: Structure.kinds[:subcommittee] }) }
  scope :by_structure_name, ->(name) { joins(:structure).where(structures: { name: name }) }

  def registration
    self.votings.find_by(topic: "Регистрация")
  end

  def prev
    sess = Session.arel_table
    structure_name = self.structure.name
    Session.by_structure_name(structure_name).where(sess[:date].lt(self.date)).order("date desc").first
  end

  def next
    sess = Session.arel_table
    structure_name = self.structure.name
    Session.by_structure_name(structure_name).where(sess[:date].gt(self.date)).order("date asc").first
  end

  def absent_votes
    absent = self.votings.order("voted_at").joins(:votes).where("votes.value" => "absent").count
    votings = self.votings.count
    absent.to_f/votings
  end

  def absent
    self.votes.absent
  end

  def absent_count
    self.absent.count
  end

  def absent_count_by_voting
    data = self.absent.joins(:voting).group("votings.voted_at").count
    data.map { |d| [d[0].to_datetime.strftime('%H:%M'), d[1]] }
  end

  def votes_by_voting
    participation = Participation.arel_table
    date = self.date

    self.votes.joins({ member: :structures }).order("votings.voted_at")
    .where((participation[:start_date].lt(date)).and(participation[:end_date].gt(date)).or(
           (participation[:start_date].lt(date)).and(participation[:end_date].eq(nil))))
    .where(structures: { kind: Structure.kinds[:party]})
    .group("votings.voted_at", "structures.name", "members.id", "members.first_name", "members.last_name", "value").count
  end

end
