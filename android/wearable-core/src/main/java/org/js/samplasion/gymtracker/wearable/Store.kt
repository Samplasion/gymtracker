package org.js.samplasion.gymtracker.wearable

import android.content.Context
import androidx.room.*
import kotlinx.coroutines.flow.Flow
import org.json.JSONObject

@Entity(tableName = "wearable_documents", primaryKeys = ["kind", "key"])
data class Document(val kind: String, val key: String, val body: String)
@Dao
interface DocumentDao {
    @Query("SELECT * FROM wearable_documents WHERE kind = :kind AND `key` = :key")
    suspend fun get(kind: String, key: String): Document?
    @Query("SELECT * FROM wearable_documents WHERE kind = :kind")
    suspend fun list(kind: String): List<Document>
    @Query("SELECT * FROM wearable_documents")
    fun observe(): Flow<List<Document>>
    @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun put(doc: Document)
    @Query("DELETE FROM wearable_documents WHERE kind = :kind AND `key` = :key") suspend fun remove(kind: String, key: String)
}
@Database(entities = [Document::class], version = 1, exportSchema = false)
abstract class WearableDatabase : RoomDatabase() {
    abstract fun documents(): DocumentDao
    companion object {
        @Volatile private var instance: WearableDatabase? = null
        fun get(context: Context): WearableDatabase = instance ?: synchronized(this) {
            instance ?: Room.databaseBuilder(context.applicationContext, WearableDatabase::class.java, "gymbro-wearable-v1.db")
                .build().also { instance = it }
        }
    }
}
class Store(context: Context) {
    val db = WearableDatabase.get(context)
    val dao = db.documents()
    suspend fun get(kind: String, key: String = "current") = dao.get(kind, key)?.let { JSONObject(it.body) }
    suspend fun put(kind: String, value: JSONObject, key: String = "current") = dao.put(Document(kind, key, value.toString()))
    suspend fun remove(kind: String, key: String = "current") = dao.remove(kind, key)
    suspend fun list(kind: String) = dao.list(kind).map { JSONObject(it.body) }
    suspend fun <T> transaction(block: suspend () -> T): T = db.withTransaction { block() }
}
