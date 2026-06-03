//
//  CloudFunctionsMock.swift
//  YukDebat
//
//  Created by Mario Ruby Ariesusandi  on 29-05-2026.
//

import Foundation

/// Mock implementation for proxying Cloud Function calls.
class CloudFunctionsMock: CloudFunctionsProtocol {

    private let motionPool = [
        "Kita harus menghentikan segala bentuk eksplorasi ruang angkasa sebelum seluruh masalah kemiskinan di Bumi terselesaikan",
        "Pemerintah perlu mewajibkan setiap warga negara untuk mengikuti program pelatihan literasi digital selama satu tahun penuh setelah lulus SMA",
        "Kepemilikan hak cipta atas karya seni yang dihasilkan oleh AI seharusnya tidak diberikan kepada siapa pun (menjadi milik publik)",
        "Penyelenggaraan konser musik skala besar harus dilarang demi menekan jejak karbon yang dihasilkan oleh mobilitas penonton",
        "Kehidupan di kota besar sebaiknya tidak lagi diukur berdasarkan pendapatan ekonomi, melainkan berdasarkan skor aksesibilitas ruang terbuka hijau",
        "Setiap individu harus memiliki batas maksimal penggunaan data internet per bulan demi keberlangsungan ekosistem server global",
        "Kita sebaiknya mewajibkan setiap politisi untuk menjalani tes psikologi independen secara berkala di depan publik",
        "Warisan kekayaan pribadi di atas 10 miliar rupiah harus disita oleh negara secara otomatis untuk dana pendidikan nasional",
        "Hubungan romantis di tempat kerja seharusnya dilarang keras demi menjaga profesionalisme dan produktivitas organisasi",
        "Perusahaan rintisan (startup) tidak boleh lagi mendapatkan pendanaan dari investor asing guna menjaga kedaulatan data ekonomi dalam negeri",
    ]

    func callExternalAPI(endpoint: String, parameters: [String: Any])
        async throws -> [String: Any]
    {
        try await Task.sleep(nanoseconds: 500_000_000)

        let selectedMotion =
            motionPool.randomElement()
            ?? "Dewan ini akan mendukung transisi energi hijau secara penuh"

        return [
            "id": UUID().uuidString,
            "title": selectedMotion,
            "category": "Sosio-Kultural",
        ]
    }

    func triggerCronScheduler() async throws {
        print("Mock: Background cron job triggered.")
    }
}
