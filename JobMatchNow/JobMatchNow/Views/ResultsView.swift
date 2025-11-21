import SwiftUI

struct ResultsView: View {
    // Placeholder job data
    let placeholderJobs = [
        JobCard(title: "iOS Developer", company: "Tech Corp", location: "Remote", matchScore: 95),
        JobCard(title: "Senior Swift Engineer", company: "StartupXYZ", location: "San Francisco, CA", matchScore: 88),
        JobCard(title: "Mobile App Developer", company: "Digital Solutions", location: "New York, NY", matchScore: 82),
        JobCard(title: "Software Engineer", company: "Innovation Labs", location: "Austin, TX", matchScore: 78)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your Job Matches")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Found \(placeholderJobs.count) matches based on your résumé")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 24)

            // Job cards list
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(placeholderJobs) { job in
                        JobCardView(job: job)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Placeholder for settings/filter
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                }
            }
        }
    }
}

// Model for job card
struct JobCard: Identifiable {
    let id = UUID()
    let title: String
    let company: String
    let location: String
    let matchScore: Int
}

// Job card component
struct JobCardView: View {
    let job: JobCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with match score
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(job.company)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()

                // Match score badge
                VStack(spacing: 4) {
                    Text("\(job.matchScore)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(matchScoreColor)

                    Text("Match")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(matchScoreColor.opacity(0.1))
                .cornerRadius(8)
            }

            // Location
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(job.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Action button
            Button(action: {
                // Placeholder action
            }) {
                Text("View Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var matchScoreColor: Color {
        if job.matchScore >= 90 {
            return .green
        } else if job.matchScore >= 75 {
            return .orange
        } else {
            return .gray
        }
    }
}

#Preview {
    NavigationStack {
        ResultsView()
    }
}
