-- CreateTable
CREATE TABLE "Chat" (
    "chat_id" UUID NOT NULL,
    "chat_name" VARCHAR(40) NOT NULL,
    "creator_id" UUID NOT NULL,
    "shared_chat" BOOLEAN NOT NULL DEFAULT false,
    "pinned_chat" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Chat_pkey" PRIMARY KEY ("chat_id")
);

-- CreateTable
CREATE TABLE "ChatUser" (
    "id" UUID NOT NULL,
    "chat_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,

    CONSTRAINT "ChatUser_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Branch" (
    "branch_id" UUID NOT NULL,
    "branch_name" VARCHAR(30) NOT NULL,
    "chat_id" UUID NOT NULL,
    "creator_id" UUID NOT NULL,
    "chat_history" JSONB[],
    "is_main_branch" BOOLEAN NOT NULL DEFAULT false,
    "parent_branch_id" UUID,
    "has_merged" BOOLEAN NOT NULL DEFAULT false,
    "merged_to_branch_id" UUID,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Branch_pkey" PRIMARY KEY ("branch_id")
);

-- CreateTable
CREATE TABLE "Commit" (
    "commit_id" UUID NOT NULL,
    "commit_name" VARCHAR(50) NOT NULL,
    "creator_id" UUID NOT NULL,
    "chat_id" UUID NOT NULL,
    "branch_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Commit_pkey" PRIMARY KEY ("commit_id")
);

-- CreateTable
CREATE TABLE "Context" (
    "context_id" UUID NOT NULL,
    "commit_id" UUID NOT NULL,
    "summary" TEXT NOT NULL,
    "context" JSONB[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Context_pkey" PRIMARY KEY ("context_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ChatUser_chat_id_user_id_key" ON "ChatUser"("chat_id", "user_id");

-- CreateIndex
CREATE INDEX "Branch_chat_id_idx" ON "Branch"("chat_id");

-- CreateIndex
CREATE INDEX "Commit_chat_id_idx" ON "Commit"("chat_id");

-- CreateIndex
CREATE INDEX "Commit_branch_id_idx" ON "Commit"("branch_id");

-- CreateIndex
CREATE INDEX "Context_commit_id_idx" ON "Context"("commit_id");

-- AddForeignKey
ALTER TABLE "Chat" ADD CONSTRAINT "Chat_creator_id_fkey" FOREIGN KEY ("creator_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatUser" ADD CONSTRAINT "ChatUser_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "Chat"("chat_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatUser" ADD CONSTRAINT "ChatUser_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Branch" ADD CONSTRAINT "Branch_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "Chat"("chat_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Branch" ADD CONSTRAINT "Branch_creator_id_fkey" FOREIGN KEY ("creator_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Branch" ADD CONSTRAINT "Branch_parent_branch_id_fkey" FOREIGN KEY ("parent_branch_id") REFERENCES "Branch"("branch_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Branch" ADD CONSTRAINT "Branch_merged_to_branch_id_fkey" FOREIGN KEY ("merged_to_branch_id") REFERENCES "Branch"("branch_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commit" ADD CONSTRAINT "Commit_creator_id_fkey" FOREIGN KEY ("creator_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commit" ADD CONSTRAINT "Commit_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "Chat"("chat_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Commit" ADD CONSTRAINT "Commit_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "Branch"("branch_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Context" ADD CONSTRAINT "Context_commit_id_fkey" FOREIGN KEY ("commit_id") REFERENCES "Commit"("commit_id") ON DELETE RESTRICT ON UPDATE CASCADE;
