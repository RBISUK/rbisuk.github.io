import './globals.css'
import type { Metadata } from 'next'
import React from 'react'

export const metadata: Metadata = {
  title: 'RBIS Intelligence',
  description: 'RBIS main & HDR funnel',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="container mx-auto px-6 py-6">{children}</body>
    </html>
  )
}
