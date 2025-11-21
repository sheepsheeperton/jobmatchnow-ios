import SwiftUI

enum JobFilter: String, CaseIterable {
    case all = "All"
    case direct = "Direct"
    case adjacent = "Adjacent"
}

struct ResultsView: View {
    let jobs: [Job]
    @State private var selectedFilter: JobFilter = .all

    var filteredJobs: [Job] {
        switch selectedFilter {
        case .all:
            return jobs
        case .direct:
            return jobs.filter { $0.category?.lowercased() == "direct" }
        case .adjacent:
            return jobs.filter { $0.category?.lowercased() == "adjacent" }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your Job Matches")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Found \(filteredJobs.count) matches based on your résumé")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Filter segmented control
            Picker("Filter", selection: $selectedFilter) {
                ForEach(JobFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 16)

            // Job cards list
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(filteredJobs) { job in
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

// Job card component
struct JobCardView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(job.company_name)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }

                Spacer()

                // Category badge (if available)
                if let category = job.category {
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
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

            // Posted date (if available)
            if let postedAt = job.posted_at {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(postedAt)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Action button
            if let jobURL = job.job_url, let url = URL(string: jobURL) {
                Link(destination: url) {
                    Text("View Details")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {}) {
                    Text("Details Unavailable")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                .disabled(true)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    let sampleJobs = [
        Job(id: "1", job_id: "job1", title: "iOS Developer", company_name: "Tech Corp", location: "Remote", posted_at: "2 days ago", job_url: "https://example.com", source_query: "iOS developer", category: "direct"),
        Job(id: "2", job_id: "job2", title: "Senior Swift Engineer", company_name: "StartupXYZ", location: "San Francisco, CA", posted_at: "1 week ago", job_url: "https://example.com", source_query: "Swift developer", category: "direct"),
        Job(id: "3", job_id: "job3", title: "Product Manager", company_name: "Innovation Labs", location: "Austin, TX", posted_at: "3 days ago", job_url: "https://example.com", source_query: "product manager", category: "adjacent"),
        Job(id: "4", job_id: "job4", title: "UX Designer", company_name: "Design Studio", location: "New York, NY", posted_at: "5 days ago", job_url: "https://example.com", source_query: "ux designer", category: "adjacent")
    ]

    return NavigationStack {
        ResultsView(jobs: sampleJobs)
    }
}
